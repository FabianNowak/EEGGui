classdef EEGGui_Info < handle
    
    properties
        gui=[];
        fig=[];
        wh = [];
        infoLabel=[];
    end
    methods(Static)
    end
    
    methods
        function this = EEGGui_Info(gui)
            this.gui=gui;
            
            this.fig = figure('visible','off');
            this.fig.SizeChangedFcn = @(~,evt) resize(this,evt);
            this.fig.Position = [0,0,300,300];
            this.fig.WindowStyle ='modal';
            movegui(this.fig,'center');
            
            this.infoLabel = uicontrol(this.fig,'Style','text');
            this.infoLabel.HorizontalAlignment = 'left';
            this.infoLabel.String = sprintf('%s\n%s',this.artifactInfo(),this.burstSuppInfo());
            this.infoLabel.Position=this.infoLabel.Extent;
            this.fig.Visible='on';
        end
        
        
        function resize(this,evt)
            this.wh=this.fig.Position(4);
            
            %infoLabel
            blx = 20;
            bly=20;
            blw = this.infoLabel.Position(3);
            blh = this.infoLabel.Position(4);
            this.set_pos(this.infoLabel,blx,bly,blw,blh);
            
            
            
        end
        
        
        function text = burstSuppInfo(this)
            data = this.gui.data(:,1);
            bs = burstsupp.detectBS(data,this.gui.sr);
            burst = sum(logical(bs));
            supp = sum(~bs);
            total = length(bs);
            burstsFrac=burst/total;
            suppFrac=supp/total;
            text='';
            if(isempty(bs))
                text = sprintf('%sBursts: ---\n',text);
            else
                text = sprintf('%sBursts: %0.2f%%\n',text,burstsFrac*100);
            end
            
            if(isempty(bs))
                text = sprintf('%Suppression: ---\n',text);
            else
                text = sprintf('%sSuppression: %0.2f%%\n',text,suppFrac*100);
            end
        end
        
        function text = artifactInfo(this)
            ampArtFrac = sum(isnan(this.gui.ampArtifactVector))/length(this.gui.ampArtifactVector);
            if(isnan(ampArtFrac))
               ampArtFrac=0; 
            end
            text='';
            text = sprintf('%sAmplitude artifacts: %0.2f%%\n',text,ampArtFrac*100);
            
            data = this.gui.data(:,1);
            [lowFrac,highFrac,zeroFrac,lowClipValue,highClipValue]= EEGGui_checkclipping(data,this.gui.min_clip_size);
            if(~isnan(highClipValue))
                text = sprintf('%sUpper clipping: %0.2f%% at %f\n',text,highFrac*100,highClipValue);
            else
                text = sprintf('%sUpper clipping: 0.00%%\n',text);
            end
            if(~isnan(lowClipValue))
                text = sprintf('%sLower clipping: %0.2f%% at %f\n',text,lowFrac*100,lowClipValue);
            else
                text = sprintf('%sLower clipping: 0.00%%\n',text);
            end
            text = sprintf('%sZero line: %0.2f%%\n',text,zeroFrac*100);
            
            total = ampArtFrac+lowFrac+highFrac+zeroFrac;
            
            text = sprintf('%sTotal artifacts: %0.2f%%\n',text,total*100);
            
        end
        
        function set_pos(this,control,x,y,w,h)
            control.Position=[x,this.wh-y-h,w,h];
        end
    end
end

