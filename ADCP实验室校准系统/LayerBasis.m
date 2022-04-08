function [waterDpl,layerBasis] = LayerBasis(t,emit,soundSpeed,layerSpeed,fc)


runType = GlobalVars();
if runType == 0
    sensorNum = 4;
else
    sensorNum = 1;
end
layerBasis = zeros(sensorNum,length(emit));
waterDpl = zeros(sensorNum,1);

for i=1:sensorNum
    [waterDpl(i),layerBasis(i,:)] = FlowEchoBasis(t,emit,soundSpeed,layerSpeed(i),fc);
end
