classdef SpectralEntropyPlot <plots.PlotContent
    
    properties
        x
        spectralEntropy;
    end
    
    methods
        function this = SpectralEntropyPlot()
            this@plots.PlotContent();
        end
        
        function req = requiredData(~)
            req={'dsa'};
        end
        
        function setData(this,type,data)
            if strcmp(type,'dsa')
                % data contains:
                % the timestamps (x)
                % the discrete frequencies (f)
                % a length(x) by length(f) matrix containing the DSA values(z)
                this.x = data{1};
                f = data{2};
                z = data{3};
                
                % Only take frequency range from 0 to 30
                indexf30 = max(1,find(f>30,1)-1);
                
                totals = sum(z(1:indexf30,:),1);
                
                % Normalize PSD
                ps = z(1:indexf30,:)./totals; 
                
                values = ps.*log(ps);
                this.spectralEntropy = -sum(values,1)/log(length(values));
            end
        end
        
        function drawPlot(this,axes)
            cla(axes);
            if(isempty(this.spectralEntropy))
                this.drawDSARequired(axes);
            else
                plot(axes,this.x,this.spectralEntropy);
            end
        end
    end
end

