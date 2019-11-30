classdef DsaPlot < plots.PlotContent
    
    properties
        dsa;
        x;
        y;
        z;
        useDif;
        zLim;
    end
    
    methods
        function this = DsaPlot(useDif)
            this@plots.PlotContent();
            this.useDif = useDif;
        end
        
        
        function req = requiredData(this)
            if this.useDif
                req={'difdsa'};
            else
                req={'dsa'};
            end
        end
        
        function setData(this,type,data)
            required = this.requiredData();
            if strcmp(type,required{1})
                this.dsa=data;
                f = data{2};
                max_y_index = find(f>=30);
                if isempty(max_y_index)
                    max_y_index = length(f);
                else
                    max_y_index = max_y_index(1);
                end
                this.x=data{1};
                this.y=f(1:max_y_index);
                this.z=10*log10(data{3}(1:max_y_index,:));
            else
                disp('ERROR: Wrong data');
            end
        end
        
        
        function drawPlot(this,axes)
            cla(axes);
            if isempty(this.z)
                this.drawDSARequired(axes);
                return;
            end
                
                pcolor(axes,this.x,this.y,this.z);
            
            ylim(axes,[0 30]);
            shading(axes,'flat');
            axes.YDir='normal';
            colormap(axes,'jet');
        end
    end
end

