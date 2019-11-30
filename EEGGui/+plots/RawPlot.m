classdef RawPlot < plots.PlotContent
    
    properties
        gui
        data
        lines
        useDif
    end
    
    methods
        function this = RawPlot(gui,useDif)
            this@plots.PlotContent();
            this.gui = gui;
            this.useDif = useDif;
        end
        
        function req = requiredData(~)
            req={'raw'};
        end
        
        function setData(this,type,data)
            if strcmp(type,'raw')
                if ~this.useDif
                    this.data=data+this.gui.ampArtifactVector+this.gui.clipArtifactVector;
                else
                    this.data = [0;diff(data)]+this.gui.ampArtifactVector+this.gui.clipArtifactVector;
                end
            end
        end
        
        function drawPlot(this,axes) 
            cla(axes);
            
            xs = (0:length(this.data)-1)/this.gui.sr;
            plot(axes,xs,this.data);
        end
    end
    methods(Access=private)
    end
end

