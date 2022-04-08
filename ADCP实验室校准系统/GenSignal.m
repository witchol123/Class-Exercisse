function [t,emitSig] = GenSignal(waveType,phase,T,cycleNum,dtyCl,fs,para1,para2)
% waveType: 1-barker码; 
% fc: 工作/调制频率, Hz
% phase: 相位
% T: 发射周期,也代表了信号长度,s
% cycleNum: 信号的周期数
% dtyCl: 占空比
% fs: 采样频率
% para1: barker-码元数,
% para2: barker-重复次数,

% 产生Barker码
if waveType==1
    %% 
    codeSig = GenCode(waveType, para1);     % Barker码,"para1"位  
    
    tao = T*dtyCl;                          % 信号脉宽
    ptNum = round(fs*tao);
    t = 0:1/fs:T-1/fs;
    
    % codeSig = interp(codeSig, round(ptNum/para1/para2));       % 插值
    
    %      codeSig = reshape(repmat(codeSig,ptNum/para1/para2,1),[1,ptNum/para2]);% 上采样
    %      codeSig = repmat(codeSig,1,para2);
    oversamp=floor(0.02e-3*fs);
    for j=1:length(codeSig)
        for i=1:oversamp
            s1((j-1)*oversamp+i)=codeSig(j);
        end
    end
    codeSig=repmat(s1,1,4);
%     codeSig = upsample(repmat(codeSig,1,para2),ptNum/para2/para1,round(ptNum/para2/para1/2)); % 补零过采样
%     codeSig = Lpf(fs,1.5*50e3,codeSig);
    codeSig = [codeSig zeros(1,length(t)-length(codeSig))];
    t = repmat(t,1,cycleNum);
    emitSig=repmat(codeSig,1,cycleNum);     % 复制cycleNum遍
%%    
%     y=y1;
%     figure
%     plot(y)
%     
%     fs=48000;       % 采样率
%     y=repmat(y,1,2000); % 复制2000遍
%     fc = 19000;     % 载频
%     t=0:1/fs:(length(y)-1)/fs;
%     % t=t(1:end-1);
%     y = sqrt(2)*y.*cos(2*pi*fc*t);
%     
%     y=mapminmax(y,-1,1);
%     
%     [ mr ] = plot_fft( y,fs,'r' );
%     % audiowrite('ultragesture.wav',y,fs);
%     % addpath E:\声音小组\LQPHP\audiotrack\matlab_code
%     
%     % n=13;
%     n=9;
%     Wn=[17000/(fs/2) 21000/(fs/2)] %设计Butterworth低通滤波器
%     [a,b]=butter(n,Wn);
%     y1=y';
%     y31= filter(a,b,y1);
%     mr=plot_fft(y31,fs,'b');
%     figure
%     % [S,F,T,P,FC,TC] = spectrogram(y31,1024,512,1024,fs,'yaxis');%20181206  ultragesture
%     [ SS,SSS,S,F,T,P,FC,TC,A ] = STFT1( y31 );
%     
%     t=0:1/fs:((length(y31)-1)/fs);
%     
%     y3=mapminmax(y31',-1,1);
    
elseif waveType == 2
    %%
    %   LFM ：linear frequency modulation
    % %
    B  = 100e3;  % 带宽70MHz
    T  = 0.56e-3;  % 脉宽2us
    Fs = 6.25e6; % 采样率
    N = T*Fs;
    t = -T/2:1/Fs:T/2-1/Fs;
    K = B/T;
    % %
    St = exp(1j*pi*K*t.^2); %信号
    theta =  pi*K*t.^2; %信号弧度
    f = K*t; %信号频率

    figure
    subplot(2,2,1);plot(real(St));title('信号实部');
    subplot(2,2,2);plot(imag(St));title('信号虚部');
    subplot(2,2,3);plot(theta);title('信号相位 °');
    subplot(2,2,4);plot(f);title('信号频率 Hz');

    figure;
    plot(abs(fftshift(fft(St))));title('信号频谱');
    % writematrix([t; y1]','tmp.csv');
end
