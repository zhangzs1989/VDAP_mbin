%
clear

velFile='/opt/swarm-2.8.0/OkmokVelocityModel.txt';

% layers2Nodes

layerMod = dlmread(velFile);
[x,y]=makeStairs(layerMod(:,1),layerMod(:,2),'back')

node(1,:) = layerMod(1,:);
for i=2:length(layerMod)
    node(i,1) = mean([layerMod(i,1),layerMod(i-1,1)]);
    node(i,2) = mean([layerMod(i,2),layerMod(i-1,2)]);
end
    
figure, hold on
plot(layerMod(:,1),-layerMod(:,2),'r-')
plot(node(:,1),-node(:,2),'bo-')
plot(x,-y,'g-')