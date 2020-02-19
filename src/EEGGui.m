classdef EEGGui < handle
    
    properties %Parameters for dsa
        dsa_segment_offset = 0.5;
        dsa_segment_length = 10;
        dsa_nfft = 512;
        useMatlabPwelch = false;
    end
    
    properties
        windowClosed = false;
        
        data = [];
        ampArtifactVector = [];
        clipArtifactVector = [];
        filename = [];
        filepath = [];
        dataname = [];
        
        lowClipInds=[];
        highClipInds=[];
        zeroInds=[];
        min_clip_size=[];
        
        plotcount = 3;
        channels=[];
        fig = [];
        subplots= matlab.graphics.axis.Axes.empty;
        menubar=[];
        rightpanel = [];
        file_open_button=[];
        genDSA_button = [];
        
        plotselectors=matlab.ui.control.UIControl.empty;
        
        linkLabel=[];
        linkCheckboxes = [];
        jumpLabel=[];
        jumpFrom = [];
        jumpTo = [];
        jumpButtons = [];
        ampArtTH_field = [];
        ampArtTH_button=[];
        clipping_checkbox=[];
        infoButton =  [];
        
        lines = [];
        filecontent = [];
        sr =[];
        tickdist=[];
        ww=[];
        subplotgap = [];
        wh=[];
        standard_dev=[];
        plot_offsets=[];
        plot_ys = [];
        plot_heights=[];
        
        zoomObj = [];
        panObj = [];
        
        doZoomX = [true,true,true];
        doZoomY = [true,true,true];
        
        ctrlPressed=false;
        shiftPressed=false;
        
        genDSA = false;
        
        closed=false;
        
        dsaData = {};
        difDsaData={};
        
        plotContents=plots.PlotContent.empty;
        plotIsUpToDate=logical([]);
        
    end %Properties
    
    methods
        function this = EEGGui()
            
            window_size = [1280,720];
            window_pos = [0,0,window_size];
            this.fig = figure('visible','off',...
                'menubar','default',...
                'toolbar','default',...
                'name', 'EEGGui',...
                'color',[0.9,0.9,0.9],...
                'position',window_pos);
            figMenuFile = findall(this.fig,'Tag','figMenuFile');
            fileMenuChildren = findall(figMenuFile);
            for child = fileMenuChildren.'
                if ~isvalid(child)
                    continue;
                end
                if strcmp(child.Tag,'figMenuFile')||strcmp(child.Tag,'figMenuFileSaveAs')
                    %ignore
                elseif strcmp(child.Tag,'figMenuOpen')
                    child.Callback = @(~,evt)on_open(this,evt);
                else
                    delete(child);
                end
            end
            figMenuEdit = findall(this.fig,'Tag','figMenuEdit');
            figMenuFile = findall(this.fig,'Tag','figMenuView');
            figMenuHelp = findall(this.fig,'Tag','figMenuHelp');
            figMenuInsert = findall(this.fig,'Tag','figMenuInsert');
            delete(figMenuEdit);
            delete(figMenuFile);
            delete(figMenuHelp);
            delete(figMenuInsert);
            pushToolNewFigure = findall(this.fig,'Tag','Standard.NewFigure');
            pushToolSaveFigure = findall(this.fig,'Tag','Standard.SaveFigure');
            pushToolPrintFigure = findall(this.fig,'Tag','Standard.PrintFigure');
            pushToolFileOpen = findall(this.fig,'Tag','Standard.FileOpen');
            pushToolFileOpen.ClickedCallback = @(~,evt)on_open(this,evt);
            delete(pushToolNewFigure);
            delete(pushToolSaveFigure);
            delete(pushToolPrintFigure);
            toggleToolInsertLegend = findall(this.fig,'Tag','Annotation.InsertLegend');
            toggleToolLinking = findall(this.fig,'Tag','DataManager.Linking');
            delete(toggleToolInsertLegend);
            delete(toggleToolLinking);
            toggleToolInsertColorbar = findall(this.fig,'Tag','Annotation.InsertColorbar');
            toggleToolInsertColorbar.OnCallback = @(~,evt) this.set_colorbar(evt,'on');
            toggleToolInsertColorbar.OffCallback = @(~,evt) this.set_colorbar(evt,'off');
            toggleToolInsertColorbar.ClickedCallback = [];
            figMenuAnalyze = uimenu(this.fig,'Text','Analyze','Tag','figMenuAnalyze');
            figMenuQuality = uimenu(figMenuAnalyze,'Text','Data/Quality Info','Tag','figMenuQuality');
            figMenuQuality.Callback = @(~,evt) EEGGui_Info(this);
            
            %Insert "Analyze" in front of "Tools"
            children = allchild(this.fig);
            for toolsIndex = 1:length(children)
                if strcmp(children(toolsIndex).Tag,'figMenuTools')
                    break;
                end
            end
            if toolsIndex<length(children)
                pos = toolsIndex-1;
                order = [2:pos,1,pos+1:length(children)];
                this.fig.Children = children(order);
            end
            
            
            this.fig.WindowScrollWheelFcn = @(~,scrolldata) this.on_mouse_wheel(scrolldata);
            this.fig.KeyPressFcn = @(~,evt) this.on_key_press(evt);
            this.fig.KeyReleaseFcn = @(~,evt) this.on_key_release(evt);
            this.fig.SizeChangedFcn = @(~,evt) this.resize(evt);
            
            this.zoomObj = zoom(this.fig);
            this.panObj = pan(this.fig);
            this.panObj.Motion = 'horizontal';
            
            movegui(this.fig,'center');
            
            
            this.subplots(1)=subplot(this.plotcount,1,1,...
                'Parent',this.fig,...
                'units','pixels');
            this.subplots(2)=subplot(this.plotcount,1,2,...
                'Parent',this.fig,...
                'units','pixels');
            this.subplots(3)=subplot(this.plotcount,1,3,...
                'Parent',this.fig,...
                'units','pixels');
            
            for p = this.subplots
                p.Toolbar.Visible='on';
                p.Color = [0.95,0.95,0.95];
            end
            
           
            
            this.rightpanel = uipanel('parent', this.fig,...
                'backgroundcolor',[0.87,0.87,0.87],...
                'units','pixels',...
                'bordertype','none');
            
            this.file_open_button = uicontrol(this.rightpanel,'Style','pushbutton');
            this.file_open_button.String='Open';
            this.file_open_button.Callback = @(~,evt) on_open(this,evt);
            
            for i = 1:this.plotcount
                this.plotselectors(i) = uicontrol(this.rightpanel,'Style','popupmenu');
                this.plotselectors(i).Callback = @(~,evt) on_plot_content_change(this,evt,i);
                this.plotselectors(i).Enable='on';
            end
            
            
            this.linkLabel = uicontrol(this.rightpanel,'Style','text');
            this.linkLabel.String = 'Link Plots';
            this.linkLabel.BackgroundColor= [0.87,0.87,0.87];
            
            for i = 1:this.plotcount
                cb = uicontrol(this.rightpanel,'Style','checkbox');
                cb.String=sprintf('Plot %d',i);
                cb.HorizontalAlignment = 'Center';
                cb.Callback = @(~,evt) on_link_checkbox(this,evt,i);
                cb.BackgroundColor = [0.87,0.87,0.87];
                cb.Value=1;
                this.linkCheckboxes(i)=cb;
            end
            linkaxes(this.subplots,'x');
            
            
            this.jumpLabel = uicontrol(this.rightpanel,'Style','text');
            this.jumpLabel.String='Jump To Region';
            this.jumpLabel.BackgroundColor = [0.87,0.87,0.87];
            
            this.jumpFrom = uicontrol(this.rightpanel,'Style','edit');
            this.jumpFrom.String='10s';
            this.jumpTo = uicontrol(this.rightpanel,'Style','edit');
            this.jumpTo.String='1min 20s';
            
            for i = 1:this.plotcount
                jb = uicontrol(this.rightpanel,'Style','pushbutton');
                jb.String = sprintf('Plot %d',i);
                jb.Callback = @(~,evt) on_jump_clicked(this,evt,i);
                this.jumpButtons(i) = jb;
            end
            
            this.genDSA_button = uicontrol(this.rightpanel,'Style','pushbutton');
            this.genDSA_button.String = 'Generate DSA';
            this.genDSA_button.Callback=@(~,evt) on_genDSA_button_Click(this,evt);
            
            this.ampArtTH_field = uicontrol(this.rightpanel,'Style','edit');
            this.ampArtTH_field.String = '';
            
            this.ampArtTH_button = uicontrol(this.rightpanel,'Style','pushbutton');
            this.ampArtTH_button.String = 'Apply Threshold';
            this.ampArtTH_button.Callback = @(~,evt) on_apply_threshold(this,evt);
            
            this.clipping_checkbox = uicontrol(this.rightpanel,'Style','checkbox');
            this.clipping_checkbox.String = 'Remove Clipping';
            this.clipping_checkbox.Callback = @(~,evt) on_clipping_toggle(this,evt);
            this.clipping_checkbox.BackgroundColor = [0.87,0.87,0.87];
            
            this.infoButton = uicontrol(this.rightpanel,'Style','pushbutton','String','Data/Quality Info');
            this.infoButton.Callback = @(~,evt) EEGGui_Info(this);
            
            EEGGui_register_plots(this);
            
            for ps = this.plotselectors
                ps.Value=1;
            end
            
            this.fig.Visible='on';
            pause(0.5);
            this.on_open([]);
        end
        
        function addplot(this,name,plot)
            l=length(this.plotContents);
            this.plotContents(l+1)=plot;
            for ps = this.plotselectors
                ps.String{l+1} = name;
            end
            this.plotIsUpToDate(l+1) = true;
        end
        
        function resize(this,~)
            this.ww = this.fig.Position(3);
            this.wh = this.fig.Position(4);
            w=this.ww;
            h=this.wh;
            
            %Plot (axes)
            px = w*0.05;% 60px border left
            py = h*0.05;% 60px border bottom
            pw = w*0.7-80;% 60px border right and left
            ph = h*0.9;% 60px border top and bottom
            this.subplotgap = h*0.04;
            spg = this.subplotgap;
            sph = (ph-spg*(this.plotcount-1))/this.plotcount;
            
            for i = 1:length(this.subplots)
                ax = this.subplots(this.plotcount-i+1);
                ax.Position(4)=sph;
                ax.Position(3)=pw;
                ax.Position(1)=px;
                ax.Position(2)=py+(i-1)*(sph+spg);
            end
            for i = 1:length(this.subplots)
                ax = this.subplots(i);
                this.plot_ys(i) = 1.0*ax.Position(2);
                this.plot_heights(i) = 1.0*ax.Position(4);
            end
            
            %rightpanel
            rpx = px+pw+20;
            rpy = py;
            rpw = w*0.3-20;
            rph = h*0.9;
            this.set_pos(this.rightpanel,rpx,rpy,rpw,rph);
            
            %file_open_button
            ofx = 20;
            ofy = 20;
            ofw = this.file_open_button.Position(3);
            ofh = this.file_open_button.Position(4);
            this.set_pos(this.file_open_button,ofx,ofy,ofw,ofh);
            
            %generateDSA
            gdx = ofx+ofw+20;
            gdy = 20;
            gdw = max(70,min(150,rpw-40-ofw));
            gdh = this.genDSA_button.Position(4);
            this.set_pos(this.genDSA_button,gdx,gdy,gdw,gdh);
            
            %linkLabel
            llx = 20;
            lly=gdy+gdh+30;
            llw = rpw-40;
            llh = this.linkLabel.Position(4);
            this.set_pos(this.linkLabel,llx,lly,llw,llh);
            %linkCheckboxes
            lcx = 20;
            lcy = lly+llh+00;
            maxlch=0;
            lcw = (rpw-80)/3;
            for cbN = this.linkCheckboxes
                cb = handle(cbN);
                lch = cb.Position(4);
                if lch>maxlch
                    maxlch=lch;
                end
                actualW = cb.Position(3);
                actualX = lcx+(lcw-actualW)/2;
                this.set_pos(cb,actualX,lcy,actualW,lch);
                lcx = lcx+lcw+20;
            end
            
            %jumpLabel
            jlx = 20;
            jly = lcy+maxlch+30;
            jlw = rpw-40;
            jlh = this.jumpLabel.Position(4);
            this.set_pos(this.jumpLabel,jlx,jly,jlw,jlh);
            %jumpFrom/jumpTo
            jex = 20;
            jey = jly+jlh+0;
            jew = (rpw-60)/2;
            jeh = this.jumpFrom.Position(4);
            this.set_pos(this.jumpFrom,jex,jey,jew,jeh);
            jex=jex+jew+20;
            this.set_pos(this.jumpTo,jex,jey,jew,jeh);
            %jumpButtons
            jpx = 20;
            jpy = jey+jeh+10;
            jpw = (rpw-80)/3;
            for jpN = this.jumpButtons
                jp = handle(jpN);
                jph = jp.Position(4);
                this.set_pos(jp,jpx,jpy,jpw,jph);
                jpx = jpx+jpw+20;
            end
            
            %ampArtTH_field
            afx = 20;
            afy = jpy+jph+40;
            afw = this.ampArtTH_field.Position(3);
            afh = this.ampArtTH_field.Position(4);
            this.set_pos(this.ampArtTH_field,afx,afy,afw,afh);
            
            %ampArtTH_button
            abx = afx+afw+20;
            aby = afy;
            abw = max(70,min(150,rpw-40-afw));
            abh = this.ampArtTH_button.Position(4);
            this.set_pos(this.ampArtTH_button,abx,aby,abw,abh);
            
            %clipping_checkbox
            ccx = 20;
            ccy = afy+afh+20;
            ccw = 150;
            cch = this.clipping_checkbox.Position(4);
            this.set_pos(this.clipping_checkbox,ccx,ccy,ccw,cch);
            
            %infoButton
            ibx = 20;
            iby = ccy+cch+20;
            ibw = this.infoButton.Position(3)*2;
            ibh = this.infoButton.Position(4);
            this.set_pos(this.infoButton,ibx,iby,ibw,ibh);
            
            %plotselectors
            
            psx = 20;
            psy = 20+rph/3*2;
            psw = rpw-40;
            for ps = this.plotselectors
                psh = ps.Position(4);
                
                this.set_pos(ps,psx,psy,psw,psh);
                
                psy = psy+psh+10;
            end
            
            
            
        end
        
        %Converts origin to top left, so that the layout can be built from top to
        %bottom
        function set_pos(~,parent,x,y,w,h)
            
            if ~isempty(w)
                parent.Position(3)=w;
            end
            if ~isempty(h)
                parent.Position(4)=h;
                
            end
            parent.Position(1)=x;
            parent.Position(2)=parent.Parent.Position(4)-y-parent.Position(4);
        end
        
        function on_key_press(this,evt)
            if any(strcmp(evt.Modifier,'control'))
                this.ctrlPressed = true;
            end
            if any(strcmp(evt.Modifier,'shift'))
                this.shiftPressed=true;
            end
            if strcmp(evt.Key,'leftarrow') || strcmp(evt.Key,'rightarrow')
                for i = 1:this.plotcount
                    ax=this.subplots(i);
                    
                    cp = ax.CurrentPoint;
                    
                    point = cp([1,3]);
                    xl = xlim(ax);
                    yl = ylim(ax);
                    if point(1)>xl(1) && point(1)<xl(2) && point(2)>yl(1)&&point(2)<yl(2)
                        w = xl(2)-xl(1);
                        if strcmp(evt.Key,'rightarrow')
                            this.move_plot(i,-w*0.1,0);
                        else
                            this.move_plot(i,w*0.1,0);
                        end
                    end
                end
            end
        end
        
        function on_key_release(this,evt)
            if ~any(strcmp(evt.Modifier,'control'))
                this.ctrlPressed=false;
            end
            
            if ~any(strcmp(evt.Modifier,'shift'))
                this.shiftPressed=false;
            end
        end
        
        function set_colorbar(this,~,state)
            if strcmp(state,'on')
                colorbar(this.subplots(1));
                colorbar(this.subplots(2));
                colorbar(this.subplots(3));
            elseif strcmp(state,'off')
                colorbar(this.subplots(1),'off');
                colorbar(this.subplots(2),'off');
                colorbar(this.subplots(3),'off');
            end
        end
        
        
        function move_plot(this,i,deltaX,deltaY)
            ax = this.subplots(i);
            xl = xlim(ax);
            yl = ylim(ax);
            xl = xl-deltaX;
            yl = yl-deltaY;
            xlim(ax,xl);
            ylim(ax,yl);
        end
        
        function on_mouse_wheel(this,scrolldata)
            for i = 1:this.plotcount
                ax=this.subplots(i);
                
                cp = ax.CurrentPoint;
                
                point = cp([1,3]);
                xl = xlim(ax);
                yl = ylim(ax);
                if point(1)>xl(1) && point(1)<xl(2) && point(2)>yl(1)&&point(2)<yl(2)
                    zoomX = true;
                    zoomY = true;
                    if this.ctrlPressed&&~this.shiftPressed
                        zoomX=false;
                    end
                    if this.shiftPressed&&~this.ctrlPressed
                        zoomY=false;
                    end
                    zoomX = zoomX && this.doZoomX(i);
                    zoomY = zoomY && this.doZoomY(i);
                    if zoomY
                        
                        %ymid = (yl(1)+yl(2))/2;
                        ymid=point(2);
                        yd = yl(2)-ymid;
                        yd = yd*1.1^scrolldata.VerticalScrollCount;
                        yl(2) = ymid+yd;
                        yd = yl(1)-ymid;
                        yd = yd*1.1^scrolldata.VerticalScrollCount;
                        yl(1) = ymid+yd;
                        ylim(ax,yl);
                    end
                    
                    if zoomX
                        % xmid = (xl(1)+xl(2))/2;
                        xmid=point(1);
                        xd = xl(2)-xmid;
                        xd = xd*1.1^scrolldata.VerticalScrollCount;
                        xl(2)=xmid+xd;
                        xd = xl(1)-xmid;
                        xd = xd*1.1^scrolldata.VerticalScrollCount;
                        xl(1) = xmid+xd;
                        xlim(ax,xl);
                    end
                    
                end
            end
        end
        
        function on_plot_content_change(this,evt,plotInd,varargin)
            if isempty(this.data)
                return;
            end
            p = inputParser;
            addRequired(p,'this');
            addRequired(p,'evt');
            addRequired(p,'plotInd');
            addOptional(p,'keepX',1);
            
            parse(p,this,evt,plotInd,varargin{:});
            
            ax = this.subplots(plotInd);
            pc = this.plotContents(this.plotselectors(plotInd).Value);
            
            x = xlim(ax);
            pc.drawPlot(ax);
            if(p.Results.keepX==1)
                
                xlim(ax,x);
            end
        end
        
        function on_link_checkbox(this, ~ ,ind)
            toLink = [];
            lim=[];
            for i = 1:length(this.linkCheckboxes)
                cb = handle(this.linkCheckboxes(i));
                if(cb.Value==1)
                    toLink(length(toLink)+1)=this.subplots(i);
                    if i~=ind && isempty(lim)
                        lim = xlim(this.subplots(i));
                    end
                end
            end
            if ~isempty(lim)
                xlim(this.subplots(ind),lim);
            end
            
            linkaxes(this.subplots,'off');
            if length(toLink)>1
                linkaxes(toLink,'x');
            end
        end
        
        function [value,stringInterpretation] = parse_threshold(this,str)
            value=0;
            if isempty(str)
                value=0;
                stringInterpretation='';
                return;
            end
            [match,group] = regexp(str,'(?<val>\d+(\.\d+)?)(?<unit>(SD|MAD))?','match','names');
            if ~isempty(match)
                v = str2double(group(1).val);
                unit = group(1).unit;
                if ~isempty(unit)
                    if strcmp(unit,'SD')
                        sd = std(this.data);
                        v=sd*v;
                    elseif strcmp(unit,'MAD')
                        md = mad(this.data);
                        v=md*v;
                    end
                end
                
                value=v;
                stringInterpretation=match{1};
            else
                stringInterpretation='';
            end
        end
        
        function [inSec,stringInterpretation] = parse_timestamp(this,str)
            stringInterpretation=str;
            if strcmp(str,'start')
                inSec = 0;
                stringInterpretation = num2str(inSec);
                return;
            end
            if strcmp(str,'end')
                inSec = length(this.data)/this.sr;
                stringInterpretation = num2str(inSec);
                return;
            end
            [match,group] = regexp(str,'(?<sign>[-\+])?(?<sec>\d+(\.\d+)?)s?','match','names');
            if length(match)==1 && strcmp(match{1},str)
                sign = group.sign;
                if strcmp(sign,'-')
                    sign=-1;
                else
                    sign=1;
                end
                sec = str2double(group.sec);
                inSec=sign+sec;
                return;
            end
            [match,group] = regexp(str,'(?<sign>[-\+])?(?<min>\d+)min\s+(?<sec>\d+(\.\d+)?)s','match','names');
            if length(match)==1 && strcmp(match{1},str)
                sign = group.sign;
                if strcmp(sign,'-')
                    sign=-1;
                else
                    sign=1;
                end
                min = str2double(group.min);
                sec = str2double(group.sec);
                inSec = sign*min*60+sec;
                return;
            end
            [match,group] = regexp(str,'(?<sign>[-\+])?(?<min>\d+(\.\d+)?)min','match','names');
            if length(match)==1 &&strcmp(match{1},str)
                sign = group.sign;
                if strcmp(sign,'-')
                    sign=-1;
                else
                    sign=1;
                end
                min = str2double(group.min);
                inSec = sign*min*60;
                return;
            end
            match = regexp(str,'[-\+]?\d+(\.\d+)?','match');
            if ~isempty(match)
                stringInterpretation=match{1};
            else
                stringInterpretation='';
            end
            inSec=str2double(stringInterpretation);
        end
        
        
        function b = is_timestamp(~,str)
            if strcmp(str,'start')
                b=true;
                return;
            end
            if strcmp(str,'end')
                b=true;
                return;
            end
            [match,~] = regexp(str,'(?<sign>[-\+])?(?<sec>\d+(\.\d+)?)s?','match','names');
            if length(match)==1 && strcmp(match{1},str)
                b=true;
                return;
            end
            [match,~] = regexp(str,'(?<sign>[-\+])?(?<min>\d+)min\s+(?<sec>\d+(\.\d+)?)s','match','names');
            if length(match)==1 && strcmp(match{1},str)
                b=true;
                return;
            end
            [match,~] = regexp(str,'(?<sign>[-\+])?(?<min>\d+(\.\d+)?)min','match','names');
            if length(match)==1 &&strcmp(match{1},str)
                b=true;
                return;
            end
            b=false;
            return;
        end
        
        function on_jump_clicked(this,~,i)
            from = this.jumpFrom.String;
            
            
            [from,stringInterpretation] = parse_timestamp(this,from);
            this.jumpFrom.String=stringInterpretation;
            
            to = this.jumpTo.String;
            
            [to,stringInterpretation] = parse_timestamp(this,to);
            this.jumpTo.String=stringInterpretation;
            
            ax = this.subplots(i);
            for p = this.subplots
                ylim(p,'manual');
            end
            if to>from
                xlim(ax,[from,to]);
            end
            
        end
        
        function on_apply_threshold(this,~)
            dialog = waitbar(0,'Updating Plots...','windowstyle','modal');
            
            thString = this.ampArtTH_field.String;
            [th,stringInterpretation] = parse_threshold(this,thString);
            this.ampArtTH_field.String = stringInterpretation;
            
            if ~isnan(th)
                this.findArtifacts(th);
                
                i = 1;
                for pc = this.plotContents
                    req = pc.requiredData();
                    if any(strcmp(req,'raw'))
                        pc.setData('raw',this.data);
                    end
                    if any(strcmp(req,'dsa'))||any(strcmp(req,'difdsa'))
                        this.setPlotIsUpToDate(i,false);
                    end
                    if isvalid(dialog)
                        waitbar(i/length(this.plotContents),dialog,['Updating Plots... (',num2str(i),'/',num2str(length(this.plotContents)),')']);
                    end
                    i = i+1;
                end
                
                this.plotContents(this.plotselectors(1).Value).drawPlot(this.subplots(1));
                this.plotContents(this.plotselectors(2).Value).drawPlot(this.subplots(2));
                this.plotContents(this.plotselectors(3).Value).drawPlot(this.subplots(3));
                
                
                if isvalid(dialog)
                    waitbar(1,dialog,'Done');
                    close(dialog);
                end
                
                msgbox('To apply the new threshold to the DSA-based plots, click "Generate DSA"','Threshold Applied','info');
                
            end
        end
        
        function on_clipping_toggle(this,~)
            
            
            this.clipArtifactVector = zeros(length(this.data),1);
            if this.clipping_checkbox.Value==1
                this.clipArtifactVector(this.lowClipInds)=nan;
                this.clipArtifactVector(this.highClipInds)=nan;
                this.clipArtifactVector(this.zeroInds) = nan;
            end
            
            if sum(this.highClipInds|this.lowClipInds|this.zeroInds)==0
                return;
            end
           
            dialog = waitbar(0,'Updating Plots...','windowstyle','modal');
            
            i = 1;
            for pc = this.plotContents
                req = pc.requiredData();
                if any(strcmp(req,'raw'))
                    pc.setData('raw',this.data);
                end
                if any(strcmp(req,'dsa'))||any(strcmp(req,'difdsa'))
                    this.setPlotIsUpToDate(i,false);
                end
                
                if isvalid(dialog)
                    waitbar(i/length(this.plotContents),dialog,['Updating Plots... (',num2str(i),'/',num2str(length(this.plotContents)),')']);
                end
                i=i+1;
            end
            if isvalid(dialog)
                waitbar(1,dialog,'Done');
                close(dialog);
            end
            
            this.plotContents(this.plotselectors(1).Value).drawPlot(this.subplots(1));
            this.plotContents(this.plotselectors(2).Value).drawPlot(this.subplots(2));
            this.plotContents(this.plotselectors(3).Value).drawPlot(this.subplots(3));         
        end
        
        function on_genDSA_button_Click(this,~)
            this.generateDSA();
        end
        
        function on_open(this,~)
            [file,path] = uigetfile({'*.mat','MATLAB-Files (*.mat)'},'Select dataset');
            if file == 0
                return;
            end
            full = fullfile(path,file);
            this.filecontent = matfile(full);
            varnames = this.read_varnames({},this.filecontent);
            EEGGui_SelectData(this,varnames);
            this.filename = file;
            this.filepath = path;
            this.fig.Name = ['EEGGui: ',file, ' (', path,file,')'];
        end
        
        function out = read_varnames(this,rootpath,var)
            names = fieldnames(var);
            out={};
            for temp = names.'
                n = temp{1};
                if strcmp(n,'Properties')
                    continue;
                end
                if isstruct(var.(n))
                    if~isempty(rootpath)
                        concat=[rootpath,n];
                    else
                        concat={n};
                    end
                    res=this.read_varnames(concat,var.(n));
                    out=[out;res];
                else
                    if ~isempty(rootpath)
                        out=[out;{[rootpath,n]}];
                    else
                        out=[out;{{n}}];
                    end
                end
            end
            
        end
        
        function dat = retrieve_data(this,varpath)
            val = this.filecontent;
            for i = 1:length(varpath)
                val = val.(varpath{i});
            end
            dat=val;
        end
        
        
        
        function load_data(this,varpath,varpath_string,srIsCustom,sr,startstr,endstr)
            this.data = this.retrieve_data(varpath);
            this.dataname = varpath_string;
            dialog = waitbar(0,'Loading EEG...','windowstyle','modal');
            this.data = this.data(:,1);%Only Channel 1
            if srIsCustom==true
                this.sr = sr;
            else
                this.sr = this.retrieve_data(sr);
            end
            
            [startSec,~] = this.parse_timestamp(startstr);
            [endSec,~] = this.parse_timestamp(endstr);
            startInd = startSec*this.sr;
            endInd = endSec*this.sr;
            if startInd>endInd
               startInd = 1;
               endInd = length(this.data);
            end
            startInd = max(1,startInd);
            endInd = min(length(this.data),endInd);
            this.data = this.data(startInd:endInd);
            
            
            waitbar(0.05,dialog,'Finding Artifacts...','windowstyle','modal');
            this.ampArtTH_field.String='100';
            this.findArtifacts(100);
            this.min_clip_size = max(2,round(0.05*this.sr));
            [~,~,~,~,~,this.lowClipInds,this.highClipInds,this.zeroInds]= EEGGui_checkclipping(this.data,this.min_clip_size);
            this.clipArtifactVector = zeros(length(this.data),1);
            this.channels = size(this.data,2);
            
            
            lim = [0,(length(this.data)-1)/this.sr];
            
            for ax = this.subplots
                xlim(ax,lim);
                ax.Color = [0.95,0.95,0.95];
            end
            
            
            for i = 1:length(this.plotContents)
                pc = this.plotContents(i);
                req = pc.requiredData();
                if any(strcmp(req,'raw'))
                    pc.setData('raw',this.data);
                end
                if any(strcmp(req,'dsa'))
                    pc.setData('dsa',{[],[],[]});
                end
                if any(strcmp(req,'difdsa'))
                    pc.setData('difdsa',{[],[],[]});
                end
                
                if isvalid(dialog)
                    waitbar(i/length(this.plotContents),dialog,['Loading Plots... (',num2str(i),'/',num2str(length(this.plotContents)),')']);
                end
            end
            
            this.plotContents(this.plotselectors(1).Value).drawPlot(this.subplots(1));
            this.plotContents(this.plotselectors(2).Value).drawPlot(this.subplots(2));
            this.plotContents(this.plotselectors(3).Value).drawPlot(this.subplots(3));
            close(dialog);
            if this.genDSA
                this.generateDSA();
            end
            
            
        end
        
        function findArtifacts(this,th)
            this.ampArtifactVector = zeros(length(this.data),1);
            if th~=0
                margin = round(0.5*this.sr);
                artifacts = abs(this.data)>th;
                combined = sum(artifacts,2)>0;
                indices = find(combined);
                all = zeros(length(indices)*(2*margin+1),1);
                for i = 0 : 2*margin
                    clamped = max(1,min(length(this.ampArtifactVector),indices+(i-margin)));
                    this.ampArtifactVector(clamped) = nan;
                end
            end
        end
        
        
        function setPlotIsUpToDate(this,i,value)
            old = this.plotIsUpToDate(i);
            if old==value
                return;
            end
            prefix = '(Needs DSA Update) ';
            if old==true
                for ps = this.plotselectors
                   ps.String{i} = [prefix,ps.String{i}];
                end
            else
                for ps = this.plotselectors
                    s = ps.String{i};
                    ps.String{i} = s(length(prefix)+1:length(s));
                end
            end
            this.plotIsUpToDate(i) = value;
        end
        
        function dsaCreated(this)
            for i = 1:length(this.plotContents)
                pc = this.plotContents(i);
                req = pc.requiredData();
                if any(strcmp(req,'dsa'))
                    pc.setData('dsa',this.dsaData);
                end
                if any(strcmp(req,'difdsa'))
                    pc.setData('difdsa',this.difDsaData);
                end
                this.setPlotIsUpToDate(i,true);
            end
            
            
            this.on_plot_content_change([],1,1);
            this.on_plot_content_change([],2,1);
            this.on_plot_content_change([],3,1);
        end
        
        % Same algorithm as pwelch, but a lot faster??, as only the necessary
        % parts are calculated
        function Px = altPwelch(~,x,window,NFFT,sr,U)
            M = length(x);
            L = fix(M./4.5);
            overlap = fix(L/2);
            LminusOverlap = L-overlap;
            
            k = (M-overlap)./LminusOverlap;
            k = fix(k);
            
            total = zeros(floor(NFFT/2)+1,1);
            
            for i = 0:(k-1)
                starti = 1+i*LminusOverlap;
                endi = starti+L-1;
                seg = x(starti:endi);
                seg = seg.*window;
                if(length(seg)>NFFT)
                    seg = datawrap(seg,NFFT);
                end
                X=fft(seg,NFFT);
                p=X.*conj(X)/U; %Power of each freq components
                
                p=p(1:floor(NFFT/2)+1);
                total = total+p;
            end
            Px = total./k./sr;
        end
        
        
        function generateDSA(this)
            data=this.data+this.ampArtifactVector+this.clipArtifactVector; %#ok<PROP>
            difData = [nan;diff(this.data(:,1))];
            
            f = [];
            segment_offset_in_s = this.dsa_segment_offset;
            segment_length_in_s = this.dsa_segment_length;
            segment_count = floor((length(this.data)/this.sr-segment_length_in_s)/segment_offset_in_s);
            total_length_in_s = segment_count*segment_offset_in_s;
            nfft = this.dsa_nfft;
            dsa = zeros(floor(nfft/2)+1,1+segment_count);
            difdsa = zeros(floor(nfft/2)+1,1+segment_count);
            cancelling = false;
            function cancel(~,~)
                cancelling = true;
                delete(dialog);
            end
            dialog = waitbar(0,'Generating DSA...','windowstyle','modal','CreateCancelBtn',@cancel);
            tic;
            fftWindow = hamming(fix(segment_length_in_s*this.sr/4.5));
            
            if(~this.useMatlabPwelch)
                U = fftWindow'*fftWindow;
                fVals=this.sr*(0:floor(nfft/2))/nfft;
            end
            for i = 1:segment_count
                segment_range=floor(i*segment_offset_in_s*this.sr) : floor((i*segment_offset_in_s+segment_length_in_s)*this.sr-1);
                
                segment = data(segment_range,1);%#ok<PROP>
                difSegment = difData(segment_range);
                if cancelling
                    break;
                end
                
                if(any(isnan(segment)))
                    dsa(:,i)=nan;
                    difdsa(:,i)=nan;
                else
                    %Use MATLABs pwelch function or the faster, custom
                    %version
                    if this.useMatlabPwelch
                        [psd,~] = pwelch(segment,fftWindow,[],nfft,this.sr);
                        [psd2,f] = pwelch(difSegment,fftWindow,[],nfft,this.sr);
                    else
                        
                        psd = this.altPwelch(segment,fftWindow,nfft,this.sr,U);
                        psd2 = this.altPwelch(difSegment,fftWindow,nfft,this.sr,U);
                        f=fVals;
                    end
                    dsa(:,i) = psd;
                    
                    difdsa(:,i)=psd2;
                    
                end
                if isvalid(dialog) && mod(i,floor(segment_count/15))==0
                    waitbar(i/segment_count*0.9,dialog,['Generating DSA... (',num2str(i),'/',num2str(segment_count),')']);
                elseif ~isvalid(dialog)
                    cancel();
                    break;
                end
            end
            toc;
            if cancelling
                return;
            end
            if isvalid(dialog)
                waitbar(0.9,dialog,'Generating Image');
            end
            
            
            x=0:segment_offset_in_s:total_length_in_s;
            
            this.dsaData={x,f,dsa};
            this.difDsaData={x,f,difdsa};
            
            this.dsaCreated();
            
            %pcolor(this.subplots(2),x,y,10*log10(z));
            %shading(this.subplots(2),'flat');
            
            disp('dsa generated');
            if isvalid(dialog)
                waitbar(1,dialog,'Done');
                close(dialog);
            end
            
        end
        
    end %Methods
end

