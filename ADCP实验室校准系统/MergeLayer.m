function layerEcho = MergeLayer(t,layerBasis,sndSpeed,fc,ptNum,hu,hd)
% 生成某一层的散点叠加回波

runType = GlobalVars();
if runType~=0
    sensorNum = 1;
else
    sensorNum = 4;
end
if runType==1||runType==2
    n=1;
    ptNum=1;
else
    n = 1;    % 分成100个小层
    ptNum = ceil(ptNum/n);
%     ptNum = 1;
end    
% 根据散射点数目和随机分配散射点距离、相位，求出各层回波
layerEcho = zeros(size(layerBasis));
fs = 1/(t(2)-t(1));
hi = linspace(hu,hd,n+1);
layerThick = hi(2)-hi(1);
hui = repmat(hi(1:n)',1,ptNum);
hdi = repmat(hi(2:end)',1,ptNum);
D = rand(n,ptNum)-0.5;
% D = ones(n,ptNum)-0.5;  % 调试用
dist = hui+D*layerThick;
distT = dist*2/sndSpeed;
phase = 2*pi*rand(n,ptNum);
% phase = 2*pi*zeros(n,ptNum);    % 调试用
% A = normrnd(0,1,[n,ptNum]);
% A = (A-min(min(A)))/(max(max(A))-min(min(A)))./dist;
TL=10*log10(dist)+0.6*dist;%传播损失，参数是随便取的
A=10.^(-TL/10).*normrnd(0,1,n,ptNum);%每个散射体的回波幅度为传播损失乘以一个随机数
% A=normrnd(0,1,n,ptNum)*0+1;
% A = (0.001+0.999*rand(n,ptNum))./dist;%*(1-dist/10);
% A = ones(n,ptNum);%./dist;  % 调试用
for i=1:sensorNum
    temp = zeros(1,size(layerBasis,2));
    for j=1:n
%         hui = hi(j);
%         hdi = hi(j+1);
%                 D = rand(1,1)-0.5;
%         dist = hui + D*(hdi-hui);  %目标距离(只是用的随机垂直距离,不精确,但本来就是随机的,精度无所谓)
%         distT = dist*2/sndSpeed;
%         phase = 2*pi*rand(1,1);         %随机相位
%         A = rand(1,1)/dist;  % 随机目标强度
        for k=1:ptNum
            temp = temp + ShiftSig(layerBasis,fs,fc,A(j,k),distT(j,k),phase(j,k));
%             if ptNum==1
%                 D = 0;
%                 %D = rand(1,1); % 调试用
%             else
%                 D = rand(1,1);
%             end
%     %         D = 0; % 调试用
%             D = rand(1,1)-0.5;
%             dist = hui + D*(hdi-hui);  %目标距离(只是用的随机垂直距离,不精确,但本来就是随机的,精度无所谓)
%             phase = 2*pi*rand(1,1);         %随机相位
%     %         phase = 0; % 调试用
%             distLag = round(dist*2/sndSpeed*fs);
%             phaseLag = round(phase/2/pi/fc*fs);       %相位带来的时移(实际不是fc, 是加多普勒后的f,但本来是随机的,也就无所谓了)
%             A = rand(1,1)/dist;  % 随机目标强度
%     %         A = 1/dist;
%     %         A = 1;
%             temp = temp + A*[zeros(1,distLag) layerBasis(i,phaseLag+1:end-distLag+phaseLag)];
        end
    end
    layerEcho(i,:) = temp;
end




