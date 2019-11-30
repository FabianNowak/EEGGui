%The Burst Suppression algorithm to use
%One of 'BS_threshold', 'Variance', 'ADIF', 'NLEO', 'Coastline'
function bs = detectBS(data,sr,algorithm)
if(nargin<3)
    %DEFAULT
    algorithm = 'Variance';
end

%Amplitude Thresholds and Cutoff Frequencies are the mean values of Tianle
%Feng's evaluation
%https://github.com/TianleFeng/Bachelor-thesis

struct = warning('OFF');

switch(algorithm)
    case 'BS_threshold'
        %BS_threshold
        bs = burstsupp.BS_threshold(data,sr,2,7.64);
    case 'Variance'
        %Variance
        filt = burstsupp.eegfilt(data',sr,8,0);
        bs = burstsupp.Variance(filt);
        bs = abs(bs')>7.55;
    case 'ADIF'
        %ADIF
        bs = burstsupp.ADIF(data',sr,sr/2,8);
        bs = abs(bs)>1074.55;
    case 'NLEO'
        %NLEO
        filt = burstsupp.eegfilt(data',sr,8,47);
        bs = burstsupp.NLEO(filt,sr,sr/2);
        bs = abs(bs)>411.73;
    case 'Coastline'
        %Coastline
        filt = burstsupp.eegfilt(data',sr,8,0);
        bs = burstsupp.Coastline(filt,sr/2);
        bs = abs(bs)>226.27;
    otherwise
        bs = [];
        warning(struct)
        warning('Unknown Burst Suppression Detection Algorithm')
end
warning(struct)
end

