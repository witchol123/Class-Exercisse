function dpl = CplxCorDpl(dplSigX, dplSigY)

% tau = dplSigX(2)-dplSigX(1);
k = 1; % 降采样倍数
dplSigX = resample(dplSigX, 1, k);% 使用多相滤波器实现对矢量dplSigX中的序列在原始采样率的1/k倍上重新采样
dplSigY = resample(dplSigY, 1, k);
tau = 7*0.02e-3;
len = length(dplSigX);
% N = mod(len+round(tau*4e6/k),len*2-1);
N_window=length(dplSigX);
cor_echowave=0;
tao_N = round(tau*6e6);
for nn=1:N_window-tao_N
    cor_echowave=cor_echowave+dplSigY(nn)'*dplSigY(tao_N+nn); % 右上角一撇是转置的意思
end
realp=real(cor_echowave);
imp=imag(cor_ec`1   qa howave);
temp=atan(imp/realp);
if realp<0
    if imp>5
        temp=temp+pi;
    else
        temp=temp-pi;
    end
end
f_value=temp/(2*pi)/tau;

% cor_echowave=xcorr(dplSigY,dplSigY);
% imp=imag(cor_echowave);
% realp=real(cor_echowave);
% f_value=atan(imp./realp)/(2*pi*tau);
dpl = f_value;