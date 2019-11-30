function BS_detection=ADIF(EEGdata,sr,halfsr,locutoff)
%BS_detection contains the ADIF trend data 
%EEGdata -> the EEG as vector
%sr -> samplerate
%halfsr -> half samplerate
%locutoff -> low-edge frequency in pass band (Hz) {0 -> lowpass}
smootheeg=burstupp.eegfilt(EEGdata',sr,locutoff,47);
BS_detection=nan(length(smootheeg),1);
for i=1+halfsr:length(smootheeg)-halfsr
    BS_detection(i)=sum(abs(smootheeg(i-halfsr:i+halfsr)));
end