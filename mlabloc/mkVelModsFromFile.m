function [Vp, Vs] = mkVelModsFromFile(o,maxx,xGridSize,yGridSize,zGridSize,velFile)

layerMod = dlmread(velFile);
node(1,:) = layerMod(1,:);
for i=2:length(layerMod)
    node(i,1) = mean([layerMod(i,1),layerMod(i-1,1)]);
    node(i,2) = mean([layerMod(i,2),layerMod(i-1,2)]);
end

% too coarse causes weird inaccuracies later in TTT
% xGridSize = 1000;
% yGridSize = 1000;
% zGridSize = 1000;
% d = (maxx-o)./3;
% d(1) = (maxx(1)-o(1))/6;
d = [zGridSize xGridSize yGridSize];

n = ceil((maxx - o)./d+1);
data = zeros(n);

vs_rec = 4000; %surface velocity in m/s
vs_inc = 750;
vopt = 'gradient';

if strcmpi(vopt,'homo')
    for i=1:n(1)
        data(i,:,:) = vs_rec; % homo
    end
elseif strcmpi(vopt,'gradient')
    for i=1:n(1)
        data(i,:,:) = vs_rec + (i-1)*vs_inc; % gradient
    end
else
    error('opt option')
end

Vp = givemeasepstruct(o,d,data);
vpx = data(:,1,1);
vpy = Vp.o(1):Vp.d(1):Vp.o(1)+Vp.d(1)*Vp.n(1)-Vp.d(1);

% Vq = interp1(X,V,Xq)
vpx2 = interp1(node(:,2)*1000,node(:,1)*1000,vpy);
I = isnan(vpx2);
lastvel = find(~isnan(vpx2));
vpx2(I) = vpx2(lastvel(end));

vpvs=1.78;
data = data./vpvs;

Vs = givemeasepstruct(o,d,data);
vsx = data(:,1,1);
vsy = vpy;

% figure
% plot(vpx,-vpy,'bo-',vsx,-vsy,'go-',vpx2,-vpy,'ko-')
% legend('P','S','file')
% grid on

for i=1:n(1)
    data(i,:,:) = vpx2(i); % gradient
end
Vp = givemeasepstruct(o,d,data);
vpx = data(:,1,1);
vpy = Vp.o(1):Vp.d(1):Vp.o(1)+Vp.d(1)*Vp.n(1)-Vp.d(1);

data = data./vpvs;
Vs = givemeasepstruct(o,d,data);
vsx = data(:,1,1);
vsy = vpy;

figure
plot(vpx,-vpy,'bo-',vsx,-vsy,'go-')
legend('P','S')
grid on
end


