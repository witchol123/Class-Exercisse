function ptNumLayers = PtNumInLayer(waveWid, h, density)

layerThick = h(2)-h(1);
h_u = h+10;%blindRg:layerThick:blindRg+(layerNum-1)*layerThick;
h_d = h_u+layerThick;
atanB = atan(waveWid/2*pi/180);
r = atanB*h_u;
R = atanB*h_d;
V = 1/3*pi*layerThick*(r.*r+R.*R+r.*R);
% ���Ƹ���ɢ������
ptNumLayers = ceil(density*V);%w=ceil(z)����������z�е�Ԫ��ȡ����ֵwΪ��С�ڱ������С����
