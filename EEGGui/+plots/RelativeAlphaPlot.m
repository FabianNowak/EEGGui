classdef RelativeAlphaPlot <plots.PlotContent
    
    properties
        x
        relativeAlpha
    end
    
    methods
        function this = RelativeAlphaPlot()
            this@plots.PlotContent();
        end
        
        function req = requiredData(~)
            req={'dsa'};
        end
        
        function setData(this,type,data)
            if strcmp(type,'dsa')
                
                this.x = data{1};
                
                f= data{2};
                z = data{3};
                alphaFrom = max(1,find(f>8,1)-1);
                alphaTo = min(length(f),find(f>=12,1));
                alphaRange=alphaFrom:alphaTo;
                totalTo = min(length(f),find(f>=30,1));
                totalRange = 1:totalTo;
                total = sum(z(totalRange,:),1);
                totalAlpha = sum(z(alphaRange,:),1);
                this.relativeAlpha = totalAlpha ./ total;
            end
        end
        
        function drawPlot(this,axes)
            cla(axes);
            if(isempty(this.relativeAlpha))
                this.drawDSARequired(axes);
            else
                plot(axes,this.x,this.relativeAlpha);
            end
        end
    end
end

