function lfSignal = Lpf(fs,fe,sig)

Wc=2*fe/fs;                                          %��ֹƵ��
[b,a]=butter(8,Wc,'low');  % �Ľ׵İ�����˹��ͨ�˲�

lfSignal=filter(b,a,sig);