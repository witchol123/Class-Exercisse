function shiftSig = ShiftSig(sig,fs,fc,a,t,phase)
% nÎªÕý,shiftSig(t)=sig(t+n),ÐÅºÅ×óÒÆ

nt = round(t*fs);
np = round(phase/(2*pi)*fs/fc);

% if n>=0
%     shiftSig = [sig(n+1:end) zeros(1,n)];
% else
%     shiftSig = [zeros(1,-n) sig(1:end+n)];
% end
% 
% shiftSig = a*shiftSig;
shiftSig = [sig(np+1:end) zeros(1,np)];
shiftSig = a*[zeros(1,nt) shiftSig(1:end-nt)];
