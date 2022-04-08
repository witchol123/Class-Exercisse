function layerEcho = MergeLayer(t,layerBasis,sndSpeed,fc,ptNum,hu,hd)
% ����ĳһ���ɢ����ӻز�

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
    n = 1;    % �ֳ�100��С��
    ptNum = ceil(ptNum/n);
%     ptNum = 1;
end    
% ����ɢ�����Ŀ���������ɢ�����롢��λ���������ز�
layerEcho = zeros(size(layerBasis));
fs = 1/(t(2)-t(1));
hi = linspace(hu,hd,n+1);
layerThick = hi(2)-hi(1);
hui = repmat(hi(1:n)',1,ptNum);
hdi = repmat(hi(2:end)',1,ptNum);
D = rand(n,ptNum)-0.5;
% D = ones(n,ptNum)-0.5;  % ������
dist = hui+D*layerThick;
distT = dist*2/sndSpeed;
phase = 2*pi*rand(n,ptNum);
% phase = 2*pi*zeros(n,ptNum);    % ������
% A = normrnd(0,1,[n,ptNum]);
% A = (A-min(min(A)))/(max(max(A))-min(min(A)))./dist;
TL=10*log10(dist)+0.6*dist;%������ʧ�����������ȡ��
A=10.^(-TL/10).*normrnd(0,1,n,ptNum);%ÿ��ɢ����Ļز�����Ϊ������ʧ����һ�������
% A=normrnd(0,1,n,ptNum)*0+1;
% A = (0.001+0.999*rand(n,ptNum))./dist;%*(1-dist/10);
% A = ones(n,ptNum);%./dist;  % ������
for i=1:sensorNum
    temp = zeros(1,size(layerBasis,2));
    for j=1:n
%         hui = hi(j);
%         hdi = hi(j+1);
%                 D = rand(1,1)-0.5;
%         dist = hui + D*(hdi-hui);  %Ŀ�����(ֻ���õ������ֱ����,����ȷ,���������������,��������ν)
%         distT = dist*2/sndSpeed;
%         phase = 2*pi*rand(1,1);         %�����λ
%         A = rand(1,1)/dist;  % ���Ŀ��ǿ��
        for k=1:ptNum
            temp = temp + ShiftSig(layerBasis,fs,fc,A(j,k),distT(j,k),phase(j,k));
%             if ptNum==1
%                 D = 0;
%                 %D = rand(1,1); % ������
%             else
%                 D = rand(1,1);
%             end
%     %         D = 0; % ������
%             D = rand(1,1)-0.5;
%             dist = hui + D*(hdi-hui);  %Ŀ�����(ֻ���õ������ֱ����,����ȷ,���������������,��������ν)
%             phase = 2*pi*rand(1,1);         %�����λ
%     %         phase = 0; % ������
%             distLag = round(dist*2/sndSpeed*fs);
%             phaseLag = round(phase/2/pi/fc*fs);       %��λ������ʱ��(ʵ�ʲ���fc, �ǼӶ����պ��f,�������������,Ҳ������ν��)
%             A = rand(1,1)/dist;  % ���Ŀ��ǿ��
%     %         A = 1/dist;
%     %         A = 1;
%             temp = temp + A*[zeros(1,distLag) layerBasis(i,phaseLag+1:end-distLag+phaseLag)];
        end
    end
    layerEcho(i,:) = temp;
end




