function ptNumLayers = PtNumInLayer(waveWid, h, density)

layerThick = h(2)-h(1);
h_u = h+10;%blindRg:layerThick:blindRg+(layerNum-1)*layerThick;
h_d = h_u+layerThick;
atanB = atan(waveWid/2*pi/180);
r = atanB*h_u;
R = atanB*h_d;
V = 1/3*pi*layerThick*(r.*r+R.*R+r.*R);
% 估计各层散射点个数
ptNumLayers = ceil(density*V);%w=ceil(z)函数将输入z中的元素取整，值w为不小于本身的最小整数
