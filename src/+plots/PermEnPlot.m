classdef PermEnPlot < plots.PlotContent
    properties
        gui
        H
        xs
    end
    
    methods
        function this = PermEnPlot(gui)
            this@plots.PlotContent();
            this.gui=gui;
        end
        
        function req = requiredData(~)
            req={'raw'};
        end
        
        function setData(this,type,data)
            if strcmp(type,'raw')
                % data is column vector
                
                % highpass + lowpass
                % 0.5Hz - 30Hz
                data = data';
                data = burstsupp.eegfilt(data,this.gui.sr,0.5,0);
                data = burstsupp.eegfilt(data,this.gui.sr,0,30);
                data = data';
                % remove artifacts
                data = data+this.gui.ampArtifactVector+this.gui.clipArtifactVector;
                
                % shift between segments = 0.5s
                seg_shift = this.gui.sr*0.5;
                % length of segment = 10s
                seg_length = this.gui.sr*10;
                % amount of segments
                seg_count = floor(length(data)/seg_length-1);
                
                this.H = zeros(seg_count,1);
                this.xs = zeros(seg_count,1);
                
                % length x 3 matrix, contains data shifted by 0, 1 and 2 to 
                % the right
                matrix= zeros(length(data)-(3-1),3);
                matrix(:,1) = data(1:length(data)-2);
                matrix(:,2) = data(2:length(data)-1);
                matrix(:,3)= data(3:length(data));
                % find rows with  nan
                nans = any(isnan(matrix),2);
                
                % sort index for each row -> each row contains 1, 2 and 3
                % sort indices are unique for our 6 patterns
                [~,idx] = sort(matrix,2);
                idx = idx-1; %1-3 -> 0-2
                
                % calculate unique code for each row
                %  2 1 0 -> 21
                %  2 0 1 -> 19
                %  1 2 0 -> 15
                %  1 0 2 -> 11
                %  0 2 1 -> 7
                %  0 1 2 -> 5
                p = idx(:,1)*9+idx(:,2)*3+idx(:,3);
                
                p(nans)=nan;
                
                for seg_start = 1 : seg_shift : length(data)-seg_length-(3-1)
                    seg = p(seg_start:seg_start+seg_length);
                    if any(isnan(seg))
                        Hn = nan;
                    else
                        
                        %size(b) = length(p) x 6
                        %b(:,1)-> p==21
                        %b(:,2)-> p==19
                        % ...
                        %b(:,6)-> p==5
                        %Only 21,19,15,11,7,5 are valid patterns with
                        %unique elements, ignore all invalid patterns
                        b = seg==[21 19 15 11 7 5];
                        
                        % count each pattern
                        count = sum(b,1);
                        % count all valid patterns
                        total = sum(count);
                        
                        %propability for each of the 6 patterns
                        pr = count/total;
                        % summands of the entropy formula
                        Hi = -pr.*log(pr);
                        Hi(pr==0) = 0;
                        % sum and normalize
                        Hn = sum(Hi)/log(length(Hi));
                    end
                    % y-values
                    this.H(ceil(seg_start/seg_shift)) = Hn;
                    % x-values
                    this.xs(ceil(seg_start/seg_shift)) = seg_start/this.gui.sr;
                end
            end
        end
        
        function drawPlot(this,axes)
            cla(axes);
            plot(axes,this.xs,this.H);
        end
    end
end

