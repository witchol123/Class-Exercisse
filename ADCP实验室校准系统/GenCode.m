function codeSig = GenCode(waveType,para1)
% waveType为1,表示barker码,para1为其码元数量

if waveType==1
    barker= comm.BarkerCode('Length',para1,'SamplesPerFrame',para1);%generates a bipolar Barker code
    codeSig = mapminmax(step(barker),-1,1);
    codeSig=(codeSig(:,1))';
else
    codeSig = 1;
end