function BS_detection=BS_threshold(EEGdata,sr,locutoff,amp_th)
%BS_detection detects Burst Suppression with a binary vector which shows Suppression=1 and Burst=0 
%EEGdata -> the EEG as vector
%sr -> samplerate
%locutoff -> low-edge frequency in pass band (Hz) {0 -> lowpass}
%amp_th -> amplitude threshold in uV
smootheeg = burstsupp.eegfilt(EEGdata',sr,locutoff,0); 
Supp=smootheeg;
Supp(abs(Supp)>amp_th)=nan;
Supp(1)=nan;
nsupp=find(isnan(Supp));
diffns=diff(nsupp);
suppsec=find(diffns>=sr);
BS_detection = zeros(length(smootheeg),1);
for i=1:length(suppsec)
    start=nsupp(suppsec(i));
    stop=nsupp(suppsec(i)+1);
    BS_detection(start:stop)=1;
end