classdef BurstSuppPlot < plots.PlotContent
    
    properties
        gui
        bs
        raw
    end
    
    methods
        function this = BurstSuppPlot(gui)
            this@plots.PlotContent();
            this.gui=gui;
        end
        
        function req = requiredData(~)
            req={'raw'};
        end
        
        function setData(this,type,data)
            if strcmp(type,'raw')
                this.raw=data(:,1);
                this.bs = burstsupp.detectBS(this.raw,this.gui.sr);
                this.raw=this.raw+this.gui.ampArtifactVector+this.gui.clipArtifactVector;
            end
        end
        
        function drawPlot(this,ax)
            cla(ax);
            if(isempty(this.bs))
                ax.Color = [0.95,0.95,0.95];
                return;
            end
            xs = (0:length(this.raw)-1)/this.gui.sr;
            ax.XGrid='on';
            ax.YGrid='on';
            ax.Units='pixels';
            plot(ax,xs,this.raw);
            
            
            ylimits = ylim(ax);
            
            height = ylimits(2)-ylimits(1);
            
            
            changes = find(diff(this.bs)~=0);
            
            isBurst = this.bs(1);
            
            from = 0;
            
            %Bei n Grenzen gibt es n+1 Regionen
            %Anzahl Regionen halbiert, abgerundet ist etwa die Anzahl Bursts bzw.
            %Suppressions
            allBursts =(length(changes)+1)/2;
            allSupp = (length(changes)+1)/2;
            allBursts = floor(allBursts);
            allSupp = floor(allSupp);
            %Wenn ungerade Anzahl Regionen
            if rem(length(changes)+1,2)~=0
                % 1 zu dem, welches das erste element besetzt addieren für exakte zahl
                if isBurst
                    allBursts = allBursts+1;
                else
                    allSupp = allSupp+1;
                end
            end
            
            xdataBurst =zeros(4,allBursts);
            ydataBurst=zeros(4,allBursts);
            xdataSupp=zeros(4,allSupp);
            ydataSupp=zeros(4,allSupp);
            burstCount = 1;
            suppCount=1;
            
            %changes sind alle indizes mit änderungen, hinten noch eine
            %änderung anhängen, da nach jeder änderung ein rechteck für den
            %vorherigen bereich erstellt wird
            for i = [changes',length(this.bs)]
                to = i;
                start = from/this.gui.sr;
                endd=to/this.gui.sr;
                
                
                if isBurst==1
                    
                    xdataBurst(1,burstCount)=start;
                    xdataBurst(2,burstCount)=endd;
                    xdataBurst(4,burstCount)=start;
                    xdataBurst(3,burstCount)=endd;
                    ydataBurst(1,burstCount)=-height*5;
                    ydataBurst(2,burstCount)=-height*5;
                    ydataBurst(3,burstCount)=height*5;
                    ydataBurst(4,burstCount)=height*5;
                    burstCount=burstCount+1;
                else
                    
                    xdataSupp(1,suppCount)=start;
                    xdataSupp(2,suppCount)=endd;
                    xdataSupp(4,suppCount)=start;
                    xdataSupp(3,suppCount)=endd;
                    ydataSupp(1,suppCount)=-height*5;
                    ydataSupp(2,suppCount)=-height*5;
                    ydataSupp(3,suppCount)=height*5;
                    ydataSupp(4,suppCount)=height*5;
                    suppCount=suppCount+1;
                end
                from=to;
                isBurst=~isBurst;
            end
            ylimits = ylim(ax);
            p = patch(ax,xdataBurst,ydataBurst,[0.8,0.9,0.75],'EdgeColor','none');
            uistack(p,'bottom');
            p= patch(ax,xdataSupp,ydataSupp,[0.9,0.95,1],'EdgeColor','none');
            uistack(p,'bottom');
            ax.Layer='top';
            ylim(ax,ylimits);
        end
    end
end

