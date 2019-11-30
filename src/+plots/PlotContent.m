classdef (Abstract) PlotContent < matlab.mixin.Heterogeneous & handle
    
    properties
       
    end
    
    methods
        function this = PlotContent()
            
        end
        
        function drawDSARequired(~,axes)
            t = text(axes, 0.5, 0.5,'DSA required',...
                'Units','normalized',...
                'EdgeColor','black',...
                'LineWidth',0.1,...
                'HorizontalAlignment','center',...
                'VerticalAlignment','middle');
            t.FontSize = 14;
        end
    end
    
    methods (Abstract)
        drawPlot(this,axes)
        
        req=requiredData(this)
        
        setData(this,type,data)
    end
    methods (Static,Sealed,Access=protected)
        function defaultObj = getDefaultScalarElement()
            defaultObj = RawPlot([]);
        end
        
    end
end

