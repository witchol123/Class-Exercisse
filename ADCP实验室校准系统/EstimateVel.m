function [esmtVel esmtAgl] = EstimateVel(dpl,sensorAgl,c,fc)


runType = GlobalVars();
if runType == 0
    esmtVel = c/2/fc*dpl;
    v1=esmtVel(1,:);
    v2=esmtVel(2,:);
    v3=esmtVel(3,:);
    v4=esmtVel(4,:);
    cosA = cos(sensorAgl*pi/180);
    sinA = sin(sensorAgl*pi/180);

    vx = (v1-v2)/(2*sinA);
    vy = (v3-v4)/(2*sinA);
    vz = -(v1+v2+v3+v4)/(4*cosA);

    esmtVel = sqrt(vx.^2+vy.^2);
    esmtAgl = atan(vy./vx)*180/pi;
else
    esmtVel = c/2/fc*dpl;
    esmtAgl = 0;
end


