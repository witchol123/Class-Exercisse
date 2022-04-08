function dpl = DetectEcho(procType,echoTime,echoSignal,fc,fe,layerTimes)

runType = GlobalVars();
if runType == 1
    layerNum = 1;
else
    layerNum = length(layerTimes);
end
temp = exp(j*2*pi*fc*echoTime);  % 必须一层层的, 下标加范围不能一个序列一起处理
[n,l,w] = size(echoSignal);
temp = repmat(temp,n,1,1);
echoCplx = echoSignal.*temp; % 后面加滤波和幅度归一化

fs = 1/(echoTime(2)-echoTime(1));
Wc=2*fe/fs;                                          %截止频率
[b,a]=butter(4,Wc,'low');  % 四阶的巴特沃斯低通滤波

layerPts = round(layerTimes*fs);
pts = layerPts(2) - layerPts(1);
T = pts/fs/4;
N=floor(fs*T)-1;

dpl = zeros(n,layerNum);
for i=1:n
     temp=filter(b,a,echoCplx(i,:));
%      temp=temp/max(abs(temp));
     %temp=echoCplx(i,:);

    for k=1:layerNum
        dplSigX = squeeze(echoTime(layerPts(k):layerPts(k)+pts-1));
        dplSigY = squeeze(temp(layerPts(k):layerPts(k)+pts-1));
        dpl(i,k) = CplxCorDpl(dplSigX, dplSigY);
%         layerTemp = squeeze(temp(layerPts(k):layerPts(k)+pts-1));
% %         t = echoTime(layerPts(k):layerPts(k)+pts-1);
% %         T = t(end)-t(1);
% %         temp = squeeze(echoCplx(i,layerPts(k):layerPts(k)+pts-1));
% %         temp=filter(b,a,temp);
%         cor_echowave=xcorr(layerTemp,layerTemp);
%         %tao = [-fliplr(echoTime) echoTime(2:end)];
%         imp=imag(cor_echowave);
%         realp=real(cor_echowave);
%        f_value=atan(imp./realp)/(2*pi)*fs;
% %         f_value=atan(imp./realp)/(2*pi*T);
%         dpl(i,k) = f_value(N);
    end
end