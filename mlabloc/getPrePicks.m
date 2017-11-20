function ttPre = getPrePicks(VpH,VsH,xyz)

% indices of TTT cell containing event
iz1 = floor((xyz(3)-VpH.o(2))/VpH.d(2)+1);
iz2 = ceil((xyz(3)-VpH.o(2))/VpH.d(2)+1);
ix1 = floor((xyz(1)-VpH.o(4))/VpH.d(4)+1);
ix2 = ceil((xyz(1)-VpH.o(4))/VpH.d(4)+1);
iy1 = floor((xyz(2)-VpH.o(3))/VpH.d(3)+1);
iy2 = ceil((xyz(2)-VpH.o(3))/VpH.d(3)+1);

% % case where event coord is on zero model boundary
if iz1 == 0
    iz1 = 1; iz2 = 2;
end
if ix1 == 0
    ix1 = 1; ix2 = 2;
end
if iy1 == 0
    iy1 = 1; iy2 = 2;
end

% case where event coord is on end model boundary
if iz1 == VpH.n(2)
    iz1 = VpH.n(2)-1; iz2 = VpH.n(2);
end
if ix1 == VpH.n(4)
    ix1 = VpH.n(4)-1; ix2 = VpH.n(4);
end
if iy1 == VpH.n(3)
    iy1 = VpH.n(3)-1; iy2 = VpH.n(3);
end


% case where event coord is on cell boundary
if iz1 == iz2
    iz2 = iz1 + 1;
end
if ix1 == ix2
    ix2 = ix1 + 1;
end
if iy1 == iy2
    iy2 = iy1 + 1;
end

% coords of corners of cell containing event
z1 = VpH.o(2) + VpH.d(2)*(iz1-1);
z2 = VpH.o(2) + VpH.d(2)*(iz2-1);
x1 = VpH.o(4) + VpH.d(4)*(ix1-1);
x2 = VpH.o(4) + VpH.d(4)*(ix2-1);
y1 = VpH.o(3) + VpH.d(3)*(iy1-1);
y2 = VpH.o(3) + VpH.d(3)*(iy2-1);

Xg = [x1 x2];
Yg = [y1 y2];
Zg = [z1 z2];

[X,Y,Z] = meshgrid(Xg,Yg,Zg);

% Pwave tts
ttPreP = zeros(1,VpH.n(1));
for sta = 1:VpH.n(1)
    
    % times to cell corners
    t(1,1,1) = VpH.data(sta,iz1,iy1,ix1);
    t(2,1,1) = VpH.data(sta,iz1,iy1,ix2);
    t(1,2,1) = VpH.data(sta,iz1,iy2,ix1);
    t(2,2,1) = VpH.data(sta,iz1,iy2,ix2);
    
    t(1,1,2) = VpH.data(sta,iz2,iy1,ix1);
    t(2,1,2) = VpH.data(sta,iz2,iy1,ix2);
    t(1,2,2) = VpH.data(sta,iz2,iy2,ix1);
    t(2,2,2) = VpH.data(sta,iz2,iy2,ix2);
    
    % times to event within cell
    ttPreP(sta) = interp3(X,Y,Z,t,xyz(1),xyz(2),xyz(3));
    
    % figure
    % scatter3(Xr,Yr,Zr,40,tr)
    % colorbar
    % grid on
    % hold on
    % scatter3(xyz(1),xyz(2),xyz(3),40,tEQ)
    
end

% Swave tts
ttPreS = zeros(1,VpH.n(1));
for sta = 1:VsH.n(1)
    
    % times to cell corners
    t(1,1,1) = VsH.data(sta,iz1,iy1,ix1);
    t(2,1,1) = VsH.data(sta,iz1,iy1,ix2);
    t(1,2,1) = VsH.data(sta,iz1,iy2,ix1);
    t(2,2,1) = VsH.data(sta,iz1,iy2,ix2);
    
    t(1,1,2) = VsH.data(sta,iz2,iy1,ix1);
    t(2,1,2) = VsH.data(sta,iz2,iy1,ix2);
    t(1,2,2) = VsH.data(sta,iz2,iy2,ix1);
    t(2,2,2) = VsH.data(sta,iz2,iy2,ix2);
    
    % times to event within cell
    ttPreS(sta) = interp3(X,Y,Z,t,xyz(1),xyz(2),xyz(3));
      
end

% predicted TTs to event
ttPre = [ttPreP ttPreS];