function moduleSignal = ModuleSignal(moduleType,t,signal,fc)

moduleSignal = signal.*sin(2*pi*fc*t);
% moduleSignal = sin(2*pi*fc*t);