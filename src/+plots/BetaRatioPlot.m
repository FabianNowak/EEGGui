classdef BetaRatioPlot < plots.PlotContent
    
    properties
        x
        betaRatio
    end
    
    methods
        function this = BetaRatioPlot()
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
                
                
                index30 =max(1,find(f>30,1)-1);
                index47 = min(length(f),find(f>=47,1));
                index11 = max(1,find(f>11,1)-1);
                index20 = min(length(f),find(f>=20,1));
                
                p30_47 = sum(z(index30:index47,:),1);
                p11_20 = sum(z(index11:index20,:),1);
                this.betaRatio = log(p30_47./p11_20);
            end
        end
        
        function drawPlot(this,axes)
            cla(axes);
            if(isempty(this.betaRatio))
                this.drawDSARequired(axes)
            else
                plot(axes,this.x,this.betaRatio);
            end
        end
    end
end

