function [t,emitSig] = GenSignal(waveType,phase,T,cycleNum,dtyCl,fs,para1,para2)
% waveType: 1-barker��; 
% fc: ����/����Ƶ��, Hz
% phase: ��λ
% T: ��������,Ҳ�������źų���,s
% cycleNum: �źŵ�������
% dtyCl: ռ�ձ�
% fs: ����Ƶ��
% para1: barker-��Ԫ��,
% para2: barker-�ظ�����,

% ����Barker��
if waveType==1
    %% 
    codeSig = GenCode(waveType, para1);     % Barker��,"para1"λ  
    
    tao = T*dtyCl;                          % �ź�����
    ptNum = round(fs*tao);
    t = 0:1/fs:T-1/fs;
    
    % codeSig = interp(codeSig, round(ptNum/para1/para2));       % ��ֵ
    
    %      codeSig = reshape(repmat(codeSig,ptNum/para1/para2,1),[1,ptNum/para2]);% �ϲ���
    %      codeSig = repmat(codeSig,1,para2);
    oversamp=floor(0.02e-3*fs);
    for j=1:length(codeSig)
        for i=1:oversamp
            s1((j-1)*oversamp+i)=codeSig(j);
        end
    end
    codeSig=repmat(s1,1,4);
%     codeSig = upsample(repmat(codeSig,1,para2),ptNum/para2/para1,round(ptNum/para2/para1/2)); % ���������
%     codeSig = Lpf(fs,1.5*50e3,codeSig);
    codeSig = [codeSig zeros(1,length(t)-length(codeSig))];
    t = repmat(t,1,cycleNum);
    emitSig=repmat(codeSig,1,cycleNum);     % ����cycleNum��
%%    
%     y=y1;
%     figure
%     plot(y)
%     
%     fs=48000;       % ������
%     y=repmat(y,1,2000); % ����2000��
%     fc = 19000;     % ��Ƶ
%     t=0:1/fs:(length(y)-1)/fs;
%     % t=t(1:end-1);
%     y = sqrt(2)*y.*cos(2*pi*fc*t);
%     
%     y=mapminmax(y,-1,1);
%     
%     [ mr ] = plot_fft( y,fs,'r' );
%     % audiowrite('ultragesture.wav',y,fs);
%     % addpath E:\����С��\LQPHP\audiotrack\matlab_code
%     
%     % n=13;
%     n=9;
%     Wn=[17000/(fs/2) 21000/(fs/2)] %���Butterworth��ͨ�˲���
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
    %   LFM ��linear frequency modulation
    % %
    B  = 100e3;  % ����70MHz
    T  = 0.56e-3;  % ����2us
    Fs = 6.25e6; % ������
    N = T*Fs;
    t = -T/2:1/Fs:T/2-1/Fs;
    K = B/T;
    % %
    St = exp(1j*pi*K*t.^2); %�ź�
    theta =  pi*K*t.^2; %�źŻ���
    f = K*t; %�ź�Ƶ��

    figure
    subplot(2,2,1);plot(real(St));title('�ź�ʵ��');
    subplot(2,2,2);plot(imag(St));title('�ź��鲿');
    subplot(2,2,3);plot(theta);title('�ź���λ ��');
    subplot(2,2,4);plot(f);title('�ź�Ƶ�� Hz');

    figure;
    plot(abs(fftshift(fft(St))));title('�ź�Ƶ��');
    % writematrix([t; y1]','tmp.csv');
end
