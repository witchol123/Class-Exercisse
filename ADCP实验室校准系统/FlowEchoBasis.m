function [waterDpl,flowEcho] = FlowEchoBasis(t,emit,sndSpeed,elemSpeed,fc)

waveLen = sndSpeed/fc;
waterDpl = 2*elemSpeed/waveLen;
%K = 1+waterDpl/f0;
K = 1-2*elemSpeed/sndSpeed;
Ts = t(2)-t(1);
tq=0:Ts*K:t(end);
temp = interp1(t,emit,tq,'pchip');

lenTq = length(tq);
lenTEmit = length(t);
flowEcho = zeros(size(emit));
if(lenTEmit<lenTq)
    flowEcho = temp(1:lenTEmit);
else
    flowEcho(1:lenTq) = temp;
end
