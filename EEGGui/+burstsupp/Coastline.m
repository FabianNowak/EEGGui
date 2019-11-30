function cl=Coastline(EEGdata,halfsr)
%cl contains the Coastline trend data 
%EEGdata -> the EEG as vector
%halfsr -> half samplerate
cldiff=diff(EEGdata'); cldiff=[nan;abs(cldiff)];
cl = nan(length(cldiff),1);
for i=1+halfsr:length(EEGdata)-halfsr
    cl(i)=sum(cldiff(i-halfsr:i+halfsr));
end