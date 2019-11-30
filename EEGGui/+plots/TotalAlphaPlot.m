classdef TotalAlphaPlot <plots.PlotContent
    
    properties
        x
        totalAlpha
    end
    
    
    methods
        function this = TotalAlphaPlot()
            this@plots.PlotContent();
        end
        
        function req = requiredData(~)
            req={'dsa'};
        end
        
        function setData(this,type,data)
            if strcmp(type,'dsa')
                this.x = data{1};
                
                f=data{2};
                z = data{3};
                alphaFrom = max(1,find(f>8,1)-1);
                alphaTo = min(length(f),find(f>=12,1));
                alphaRange=alphaFrom:alphaTo;
                this.totalAlpha = sum(z(alphaRange,:),1);
                
            end
        end
        
        function drawPlot(this,axes)
            cla(axes);
            if(isempty(this.dsa))
                this.drawDSARequired(axes);
            else
                plot(axes,this.x,this.totalAlpha);
                ylim(axes,[0,100]);
            end
        end
    end
end

