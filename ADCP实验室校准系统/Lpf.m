function lfSignal = Lpf(fs,fe,sig)

Wc=2*fe/fs;                                          %截止频率
[b,a]=butter(8,Wc,'low');  % 四阶的巴特沃斯高通滤波

lfSignal=filter(b,a,sig);