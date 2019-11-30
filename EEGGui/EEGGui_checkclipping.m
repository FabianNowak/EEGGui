%checkclipping(eeg_data,minClipSize,zeroTH)
%-----------------------------------------
%eeg_data: Die zu ueberpruefenden EEG-Daten
%minClipSize: Die minimale Anzahl Datenpunkte in einer als Clipping
%erkannten Region (default: 10)
%zeroTH: Der Schwellwert, unter welchem eine gerade Linie als Nullinie
%erkannt wird (default: 0.1)
%-----------------------------------------
%Gibt zurück:
%lowFrac: Anteil an unterem Clipping
%highFrac: Anteil an oberem Clipping
%zeroFrac: Anteil der Nulllinie
%lowClipValue: Wert der unteren Clippinggrenze
%highClipValue: Wert der oberen Clippinggrenze
%lowClipInds: Logical vector, der angibt, wo unteres Clipping erkannt wurde
%highClipInds: Logical vector, der angibt, wo oberes Clipping erkannt wurde
%zeroInds: Logical vector, fuer die Stellen der Nulllinie
function [lowFrac,highFrac,zeroFrac,...
    lowClipValue,highClipValue,...
    lowClipInds,highClipInds,zeroInds] =...
    EEGGui_checkclipping(varargin)
if nargin < 1
    %error
    error('Not enough arguments');
end
minClipSize=10;
zeroTH=0.01;
if nargin >= 1
    data=varargin{1};
end
if nargin>=2
    if ~isnan(varargin{2})
        zeroTH=varargin{2};
    end
end
if nargin>=3
    if ~isnan(varargin{3})
        minClipSize=varargin{3};
    end
end


dif = [nan;diff(data)];
zeroCount=0;

minAmp = nan; 
maxAmp = nan; 
minClipCount = 0;
maxClipCount=0;
lowClipInds = false(length(data),1);
highClipInds = false(length(data),1);
zeroInds = false(length(data),1);

zeroStreak = 0;
clipStreak =0;

clippingValue=nan;


for i = 1:length(dif)
    d = dif(i);
    v = data(i);
    if(d==0)
        if abs(v)<zeroTH
            zeroStreak=zeroStreak+1;
        else
            clipStreak=clipStreak+1;
            clippingValue=v;
        end
    else
        if clipStreak>=minClipSize
            from = i-clipStreak+1;
            to = i-1;
            if clippingValue==minAmp
                minClipCount=minClipCount+clipStreak;
                lowClipInds(from:to) = 1;
            elseif clippingValue==maxAmp
                maxClipCount=maxClipCount+clipStreak;
                highClipInds(from:to) = 1;
            elseif isnan(minAmp)||clippingValue<minAmp
                minAmp=clippingValue;
                minClipCount=clipStreak;
                lowClipInds(:)=0;
                lowClipInds(from:to) = 1;
            elseif isnan(maxAmp)||clippingValue>maxAmp
                maxAmp=clippingValue;
                maxClipCount=clipStreak;
                highClipInds(:)=0;
                highClipInds(from:to) = 1;
            end
        end
        
        if zeroStreak>=minClipSize
            from = i-zeroStreak+1;
            to=i-1;
            zeroCount=zeroCount+zeroStreak;
            zeroInds(from:to)=1;
        end
        clipStreak=0;
        zeroStreak=0;
    end
end

lowClipValue=minAmp;
highClipValue=maxAmp;

lowFrac = minClipCount/(length(data)-1);
highFrac = maxClipCount/(length(data)-1);
zeroFrac = zeroCount/(length(data)-1);

end

