% ��ʼ��
clc
clear
close all;

slCharacterEncoding='UTF-8';

fs = 6e6;                   % ����Ƶ��, ԭʼ48000, ����5M����
fc=600e3;                   % ����Ƶ��, ԭʼ18000, ����300k
                            % ���ȷֱ���16λ, ����0-80dB
depth = 14;                  % ������100��
c=1500;                     % ����

waveType = 1;               % 1-Barker��?
bitWid = 0.02e-3;           % ��Ԫ���,s 
waveBitNum = 7;             % ��Ԫλ��
repTimes = 4;               % �ظ�����

moduleType = 1;             % 1-QPSK
procType = 1;               % 1-��Э���?
sensorAgl = 30;             % �ĸ�������������ļн�?
waveAngle = 3;                % �������� 3��

SNRatio = 20;               % �����,dB 
fe = fc/1;                  % ���ʱ���˲���ֹƵ�� Hz
densLayer = 1000;         % ÿ�����׵�ɢ������
densBottom = 1000;          % ÿƽ���׵�ɢ������
%% ��ز�������
layerThick = bitWid*waveBitNum*repTimes*c/2;                    % ���, ��
blindRg = 1.5*layerThick;%/2;                                   % ä��, �����źź��ٸ�������. ��
% blindRg = 0.21;
dist=depth/cos((sensorAgl+waveAngle)*pi/180)+layerThick;          % ���б��(�����ز�����), ��
layerNum = floor((depth-blindRg)/layerThick)-1;                 % ����, ������ȥ��ä��, �ɲ��(������ʽ)
flowVels = linspace(0.12,1.85,layerNum);                           % ÿ�������, ��Ե��ٶ�?
% flowVels = 1*ones(1,layerNum);                           % ÿ�������, ��Ե��ٶ�?
flowAgl = 0*ones(1,layerNum);                                  % �����,������x��н�(��z�᷽��Ϊ0)?
h = blindRg:layerThick:blindRg+(layerNum-1)*layerThick;
%% �����ź�
% �͸���
[signalTime,emitSignal] = GenSignal(waveType,0,dist/c*2,1,...
    bitWid*waveBitNum*repTimes/(dist*2/c),fs,waveBitNum,repTimes);
% % ������: ȥ���͸���
% emitSignal = ones(1, round(bitWid*waveBitNum*repTimes*fs));
% emitSignal = [emitSignal zeros(1, length(signalTime)-length(emitSignal))];
% ����
moduleSignal = ModuleSignal(moduleType,signalTime,emitSignal,fc);
%% ����ģʽ����
runType = GlobalVars();
if runType==0 % ִ��ģʽ
    elemSpeed= ElemSpeed(flowVels, flowAgl, sensorAgl);  % compute waterVelocity
    ptNumLayers = PtNumInLayer(waveAngle, h, densLayer);
    sensorNum = 4;
elseif runType==1   % ���㵥������
    elemSpeed = 1;
    ptNumLayers = 1;
    layerNum = 1;
    sensorNum = 1;
elseif runType==2
    elemSpeed = flowVels;  % ��㵥������
    ptNumLayers = ones(size(h));
    % ptNumLayers = ones(size(h));    % ������
    sensorNum = 1;
else
    elemSpeed = flowVels;  % ��㵥������
    ptNumLayers = PtNumInLayer(waveAngle, h, densLayer);
    % ptNumLayers = ones(size(h));    % ������
    sensorNum = 1;
end
%% ���������ջز�
% ��ʼ��
dplarr = [];
velarr = [];
aglarr = [];
iters = 100;
for l=1:iters
    layerSignal = zeros(sensorNum,size(moduleSignal,2));
    elemDpl = zeros(sensorNum,layerNum);
    % ���Ӷ��ز�
    for i=1:layerNum
        % ÿ����һ�������������ź�
        [elemDpl(:,i),layerBasis] = LayerBasis(signalTime,moduleSignal,c,elemSpeed(:,i),fc);
    %     if i==1&&runType~=1
    %         layerSignal = layerSignal + MergeLayer(signalTime,layerBasis,c,fc,...
    %             ptNumLayers(i),h(i)-layerThick,h(i));
    %     end
        % �ڻ������γ�ɢ��ĺϳɻز�, �ٰ������
        layerSignal = layerSignal + MergeLayer(signalTime,layerBasis,c,fc,...
            ptNumLayers(i),h(i),h(i)+layerThick);
    end
    % ��һ��
    % layerSignal = layerSignal/max(layerSignal)/100;
    % layerSignal = moduleSignal; % ������,ֱ���õ��Ƶķ��䲨
    % ���ɵ׻ز�
%     bottomSignal = BottomSignal(signalTime,moduleSignal,c,fc,...
%         depth,sensorAgl,waveWid,densBottom,50);
    % ���ӷ��䲨/����ز�/�׻ز�
%     totalSignal = repmat(moduleSignal,sensorNum,1)+layerSignal;%+bottomSignal;
    totalSignal = layerSignal;%+bottomSignal;
    totalSignal = awgn(totalSignal,SNRatio,'measured');
    plot(signalTime,totalSignal);axis([0 18e-3 -inf inf ])
    %% ������ʾ
    dpl = DetectEcho(procType,signalTime,totalSignal,fc,fe,h*2/c);
    [esmtVel esmtAgl] = EstimateVel(dpl,sensorAgl,c,fc);
    dplarr = [dplarr; dpl];
    velarr = [velarr; esmtVel];
    aglarr = [aglarr; esmtAgl];
end
v_measure=mean(dplarr,1)*c/fc/2;
figure
plot(v_measure*100,'-b*')
hold on
plot(flowVels*100,'-ro')
hold on
plot(abs(flowVels-v_measure)*100,'-k^')
grid on
legend('�����ٶ�ֵ','��ʵ�ٶ�ֵ','�������')
xlabel('ˮ����')
ylabel('ˮ���ٶ�(cm/s)')
figure
plot(flowVels*100,sqrt(mean((dplarr(1:5,:)*c/fc/2-flowVels).^2,1)/5)*100,'-r*')
hold on
plot(flowVels*100,sqrt(mean((dplarr(1:10,:)*c/fc/2-flowVels).^2,1)/10)*100,'-bo')
hold on
plot(flowVels*100,sqrt(mean((dplarr(1:50,:)*c/fc/2-flowVels).^2,1)/50)*100,'-ms')
hold on
plot(flowVels*100,sqrt(mean((dplarr(1:100,:)*c/fc/2-flowVels).^2,1)/100)*100,'-k^')
hold on
grid on
legend('ƽ��5��','ƽ��10��','ƽ��50��','ƽ��100��')
figure
plot(flowVels*100,sqrt(mean((dplarr(1:100,:)*c/fc/2-flowVels).^2,1)/100)*100,'-r*')
hold on
% plot(abs(flowVels-v_measure)*100,'-k^')
% hold on
plot(flowVels*100,flowVels*100*0.25e-2+0.2,'-bo')
grid on
legend('���Ʊ�׼��','ADCP���')
xlabel('ˮ���ٶ�(cm/s)')
ylabel('�������(cm/s)')
% mean(abs((mean(dplarr)-elemDpl)./elemDpl))
%mean(abs((dplarr-elemDpl)./elemDpl))
% mean(abs((dpl-elemDpl)./elemDpl))
% % elemSpeed,esmtVel,elemDpl,dpl
% % esmtVel = c/2/fc*dpl;
% % DisplayArraySignal(signalTime*750,layerSignal,sensorNum);
% % DisplayArraySignal(signalTime*750,bottomSignal,sensorNum);
% % DisplayArraySignal(signalTime*750,totalSignal,sensorNum);
% figure;
% plot(esmtVel);
% hold on
% plot(flowVels);
% % figure;
% plot((esmtVel-flowVels)./flowVels*100,'r')
% figure
% plot(esmtAgl);
% hold on
% plot(flowAgl);
% 
% layerSignal = layerSignal + repmat(emitSignal,4,1);
% 
% echoSignal = FlowDoppler(emitTime, emitSignal,fc,c,sensorAgl,flowVels,flowAgl);
% plot(emitTime,squeeze(echoSignal(2,1,:)));


% dpl = DetectEcho(procType,signalTime,echoSignal,fc,fe);
% % esmtVel = c/2/fc*dpl;
% [esmtVel esmtAgl] = EstimateVel(dpl,sensorAgl,c,fc);
% subplot(2,1,1)
% plot(flowVels,'b')
% hold on
% plot(esmtVel,'r')
% subplot(2,1,2)
% plot([10 10 10 10 10],'b')
% hold on
% plot(esmtAgl,'r')
% figure
% subplot(2,1,1)
% plot(100*abs(esmtVel-flowVels)./flowVels,'r')
% subplot(2,1,2)
% plot(100*abs(esmtAgl-10)/10,'r')
% esmtVel,esmtAgl
        