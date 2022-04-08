% 初始化
clc         %清除命令行窗口中的数据
clear       %清除工作区中的数据
close all;  %关闭所有的Figure窗口

slCharacterEncoding='UTF-8';%将 MATLAB 字符集编码更改为指定的 encoding

fs = 6e6;                   % 采样频率,6*10^6 原始48000, 最终5M以上
fc=600e3;                   % 工作频率, 原始18000, 最终300k
                            % 幅度分辨率16位, 增益0-80dB
depth = 5;                  % 最大深度100米
c=1500;                     % 声速

waveType = 1;               % 1-Barker码?
bitWid = 0.02e-3;           % 码元宽度,s 
waveBitNum = 7;             % 码元位数
repTimes = 4;               % 重复次数

moduleType = 1;             % 1-QPSK
procType = 1;               % 1-复协方差法?
sensorAgl = 30;             % 四个传感器与主轴的夹角?
waveWid = 3;                % 波束宽度?

SNRatio = 20;               % 信噪比,dB 
fe = fc/1;                  % 解调时的滤波截止频率 Hz
densLayer = 10000;          % 每立方米的散射点个数
densBottom = 1000;          % 每平方米的散射点个数
%% 相关参数计算
layerThick = bitWid*waveBitNum*repTimes*c/2;                    % 层厚, 米
blindRg = 1.5*layerThick;%/2;                                   % 盲区, 发射信号后再跟半个层厚. 米
dist=depth/cos((sensorAgl+waveWid)*pi/180)+layerThick;          % 最大斜距(决定回波长度), 米
layerNum = floor((depth-blindRg)/layerThick)-1;                 % floor函数高斯取整，层数, 最大深度去掉盲区, 由层厚(上述公式)
flowVels = linspace(0.12,1.85,layerNum);                        % linspace用于产生x1,x2之间的N点行矢量，每层的流速, 相对的速度?
% flowVels = 1*ones(1,layerNum);                                % 每层的流速, 相对的速度?
flowAgl = 0*ones(1,layerNum);                                   % ones函数生成全1矩阵，流向角,流向与x轴夹角(在z轴方向为0)?
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
    elemSpeed= ElemSpeed(flowVels, flowAgl, sensorAgl);  % 计算水流速度
    ptNumLayers = PtNumInLayer(waveWid, h, densLayer);   % 计算每层散射体数量
    sensorNum = 4;                                       % 4层传感器
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
    ptNumLayers = PtNumInLayer(waveWid, h, densLayer);
    % ptNumLayers = ones(size(h));    % 调试用
    sensorNum = 1;
end
%% 产生多普勒回波
% 初始化
dplarr = [];
velarr = [];
aglarr = [];
iters = 50;
for l=1:iters
    layerSignal = zeros(sensorNum,size(moduleSignal,2));%返回一个a*b的0矩阵
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
    totalSignal = awgn(totalSignal,SNRatio,'measured'); % awgn：Add white Gaussian noise to signa
    %% 检测和显示
    dpl = DetectEcho(procType,signalTime,totalSignal,fc,fe,h*2/c);
    [esmtVel esmtAgl] = EstimateVel(dpl,sensorAgl,c,fc);
    dplarr = [dplarr; dpl];
    velarr = [velarr; esmtVel];
    aglarr = [aglarr; esmtAgl];
end

v_measure=mean(dplarr)*c/fc/2;
figure
plot(v_measure*100,'-b*')
hold on
plot(flowVels*100,'-ro')
hold on
plot(abs(flowVels-v_measure)*100,'-k^')
grid on % 显示轴网格线
legend('估计速度值','真实速度值','估计误差')
xlabel('水流层')
ylabel('水流速度(cm/s)')

% ex = []; ey = [];
% for i=1:10
%     ex = [ex i*floor(iters/10)];
%     ey = [ey mean((mean(dplarr(1:i*floor(iters/10),:))-elemDpl)./elemDpl)];
% end
% plot(ex,ey);
% figure
% plot(mean(dplarr),'r')
% hold on
% plot(elemDpl)
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
        