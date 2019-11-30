function BS_detection=NLEO(EEGdata,halfsr)
%BS_detection contains the NLEO trend data 
%EEGdata -> the EEG as vector
%halfsr -> half samplerate
BS_detection=nan(length(EEGdata),1);
for i=1+halfsr+3:length(EEGdata)-halfsr
    BS_detection(i)=sum(abs(EEGdata(i-halfsr:i+halfsr).*EEGdata(i-(halfsr+3):i+(halfsr-3))-EEGdata(i-(halfsr+1):i+(halfsr-1)).*EEGdata(i-(halfsr+2):i+(halfsr-2))));
end