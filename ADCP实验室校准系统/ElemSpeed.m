function [elemSpeeds] = ElemSpeed(waterSpeed, waterDir,sensorDir)

slCharacterEncoding='UTF-8';

%% compute waterVelocity
cosTheta = cos(waterDir*pi/180);
sinTheta = sin(waterDir*pi/180);
vx = waterSpeed.*cosTheta;
vy = waterSpeed.*sinTheta;
vz = zeros(1,length(vx));
%v=[vx; vy; vz];

cosAlpha = cos(sensorDir*pi/180);
sinAlpha = sin(sensorDir*pi/180);
v1 = vx*sinAlpha-vz*cosAlpha;   % 1,2 传感器相对放�?
v2 = -vx*sinAlpha-vz*cosAlpha;
v3 = vy*sinAlpha-vz*cosAlpha;   % 3,4 传感器相对放�?
v4 = -vy*sinAlpha-vz*cosAlpha;

%%
elemSpeeds = [v1;v2;v3;v4];