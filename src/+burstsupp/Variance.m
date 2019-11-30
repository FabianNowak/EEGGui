function vari=Variance(EEGdata)
%vari contains the Variance trend data 
%EEGdata -> the EEG as vector
a=9; %number of datapoints, fixed to 9
ut(a)=0.9534*mean(sum(EEGdata(1):EEGdata(8)))+(1-0.9534)*EEGdata(9);
vari(a)=0.9534*var(sum(EEGdata(1):EEGdata(8)))+(1-0.9534)*(EEGdata(9)-ut(a))^2;
for a=10:length(EEGdata)
 ut(a)=0.9534*ut(a-1)+(1-0.9534)*EEGdata(a);
 vari(a)=0.9534*vari(a-1)+(1-0.9534)*(EEGdata(a)-ut(a))^2;
end