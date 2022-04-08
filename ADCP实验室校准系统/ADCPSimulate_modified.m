% 初始化
clc
clear
close all;

slCharacterEncoding='UTF-8';

fs = 6e6;                   % 采样频率, 原始48000, 最终5M以上
fc=600e3;                   % 工作频率, 原始18000, 最终300k
                            % 幅度分辨率16位, 增益0-80dB
depth = 14;                  % 最大深度100米
c=1500;                     % 声速

waveType = 1;               % 1-Barker码?
bitWid = 0.02e-3;           % 码元宽度,s 
waveBitNum = 7;             % 码元位数
repTimes = 4;               % 重复次数

moduleType = 1;             % 1-QPSK
procType = 1;               % 1-复协方差法?
sensorAgl = 30;             % 四个传感器与主轴的夹角?
waveAngle = 3;                % 波束开角 3度

SNRatio = 20;               % 信噪比,dB 
fe = fc/1;                  % 解调时的滤波截止频率 Hz
densLayer = 1000;         % 每立方米的散射点个数
densBottom = 1000;          % 每平方米的散射点个数
%% 相关参数计算
layerThick = bitWid*waveBitNum*repTimes*c/2;                    % 层厚, 米
blindRg = 1.5*layerThick;%/2;                                   % 盲区, 发射信号后再跟半个层厚. 米
% blindRg = 0.21;
dist=depth/cos((sensorAgl+waveAngle)*pi/180)+layerThick;          % 最大斜距(决定回波长度), 米
layerNum = floor((depth-blindRg)/layerThick)-1;                 % 层数, 最大深度去掉盲区, 由层厚(上述公式)
flowVels = linspace(0.12,1.85,layerNum);                           % 每层的流速, 相对的速度?
% flowVels = 1*ones(1,layerNum);                           % 每层的流速, 相对的速度?
flowAgl = 0*ones(1,layerNum);                                  % 流向角,流向与x轴夹角(在z轴方向为0)?
h = blindRg:layerThick:blindRg+(layerNum-1)*layerThick;
%% 产生信号
% 巴格码
[signalTime,emitSignal] = GenSignal(waveType,0,dist/c*2,1,...
    bitWid*waveBitNum*repTimes/(dist*2/c),fs,waveBitNum,repTimes);
% % 调试用: 去除巴格码
% emitSignal = ones(1, round(bitWid*waveBitNum*repTimes*fs));
% emitSignal = [emitSignal zeros(1, length(signalTime)-length(emitSignal))];
% 调制
moduleSignal = ModuleSignal(moduleType,signalTime,emitSignal,fc);
%% 调试模式参数
runType = GlobalVars();
if runType==0 % 执行模式
    elemSpeed= ElemSpeed(flowVels, flowAgl, sensorAgl);  % compute waterVelocity
    ptNumLayers = PtNumInLayer(waveAngle, h, densLayer);
    sensorNum = 4;
elseif runType==1   % 单层单传感器
    elemSpeed = 1;
    ptNumLayers = 1;
    layerNum = 1;
    sensorNum = 1;
elseif runType==2
    elemSpeed = flowVels;  % 多层单传感器
    ptNumLayers = ones(size(h));
    % ptNumLayers = ones(size(h));    % 调试用
    sensorNum = 1;
else
    elemSpeed = flowVels;  % 多层单传感器
    ptNumLayers = PtNumInLayer(waveAngle, h, densLayer);
    % ptNumLayers = ones(size(h));    % 调试用
    sensorNum = 1;
end
%% 产生多普勒回波
% 初始化
dplarr = [];
velarr = [];
aglarr = [];
iters = 100;
for l=1:iters
    layerSignal = zeros(sensorNum,size(moduleSignal,2));
    elemDpl = zeros(sensorNum,layerNum);
    % 叠加多层回波
    for i=1:layerNum
        % 每层有一个基础多普勒信号
        [elemDpl(:,i),layerBasis] = LayerBasis(signalTime,moduleSignal,c,elemSpeed(:,i),fc);
    %     if i==1&&runType~=1
    %         layerSignal = layerSignal + MergeLayer(signalTime,layerBasis,c,fc,...
    %             ptNumLayers(i),h(i)-layerThick,h(i));
    %     end
        % 在基础上形成散点的合成回波, 再按层叠加
        layerSignal = layerSignal + MergeLayer(signalTime,layerBasis,c,fc,...
            ptNumLayers(i),h(i),h(i)+layerThick);
    end
    % 归一化
    % layerSignal = layerSignal/max(layerSignal)/100;
    % layerSignal = moduleSignal; % 调试用,直接用调制的发射波
    % 生成底回波
%     bottomSignal = BottomSignal(signalTime,moduleSignal,c,fc,...
%         depth,sensorAgl,waveWid,densBottom,50);
    % 叠加发射波/流层回波/底回波
%     totalSignal = repmat(moduleSignal,sensorNum,1)+layerSignal;%+bottomSignal;
    totalSignal = layerSignal;%+bottomSignal;
    totalSignal = awgn(totalSignal,SNRatio,'measured');
    plot(signalTime,totalSignal);axis([0 18e-3 -inf inf ])
    %% 检测和显示
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
legend('估计速度值','真实速度值','估计误差')
xlabel('水流层')
ylabel('水流速度(cm/s)')
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
legend('平均5次','平均10次','平均50次','平均100次')
figure
plot(flowVels*100,sqrt(mean((dplarr(1:100,:)*c/fc/2-flowVels).^2,1)/100)*100,'-r*')
hold on
% plot(abs(flowVels-v_measure)*100,'-k^')
% hold on
plot(flowVels*100,flowVels*100*0.25e-2+0.2,'-bo')
grid on
legend('估计标准差','ADCP误差')
xlabel('水流速度(cm/s)')
ylabel('测量误差(cm/s)')
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
        