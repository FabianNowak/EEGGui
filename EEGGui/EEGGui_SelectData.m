classdef EEGGui_SelectData <handle
    
    properties
        gui=[];
        fig=[];
        datadropdown=[];
        srdropdown=[];
        customfield=[];
        startfield = [];
        endfield = [];
        dddlabel=[];
        sddlabel=[];
        customlabel=[];
        
        okbutton = [];
        
        strings=[];
        attrpaths=[];
        
        ww=[];
        wh=[];
    end
    
    methods
        function this = EEGGui_SelectData(gui,attrpaths)
            this.gui=gui;
            
            this.strings={};
            this.attrpaths=attrpaths;
            for attrpath = attrpaths.'
                str= join(attrpath{1},' -> ');
                this.strings=[this.strings;str];
            end
            
            this.fig=figure('visible','off');
            this.fig.SizeChangedFcn = @(~,evt) resize(this,evt);
            this.fig.Position = [0,0,300,300];
            this.fig.WindowStyle ='modal';
            movegui(this.fig,'center');
            
            this.datadropdown = uicontrol(this.fig,'Style','popupmenu');
            this.datadropdown.String = this.strings;
            this.datadropdown.Value = 1;
            
            this.dddlabel = uicontrol(this.fig,'Style','text');
            this.dddlabel.String = 'Data';
            this.dddlabel.HorizontalAlignment='left';
            
            
            this.srdropdown = uicontrol(this.fig,'Style','popupmenu');
            this.srdropdown.String = ['--Custom--';this.strings];
            this.srdropdown.Value= 1;
            this.srdropdown.Callback = @(~,evt)srdropdown_change(this,evt);
            
            this.sddlabel = uicontrol(this.fig,'Style','text');
            this.sddlabel.String='Samplerate';
            this.sddlabel.HorizontalAlignment='left';
          
            this.customfield = uicontrol(this.fig,'Style','edit');
            this.customfield.String='250';
            this.customfield.Callback = @(~,evt)custom_textentered(this,evt);
            
            this.customlabel = uicontrol(this.fig,'Style','text');
            this.customlabel.HorizontalAlignment='left';
            this.customlabel.String='Custom';
            
            this.startfield = uicontrol(this.fig,'Style','edit');
            this.startfield.String='start';
            this.startfield.Callback = @(~,evt)startend_textentered(this,evt,this.startfield);
            
            this.endfield = uicontrol(this.fig,'Style','edit');
            this.endfield.String ='end';
            this.endfield.Callback = @(~,evt)startend_textentered(this,evt,this.endfield);
            
            this.okbutton = uicontrol(this.fig,'Style','pushbutton');
            this.okbutton.String='OK';
            this.okbutton.Callback=@(~,evt)okpressed(this,evt);
            
            this.fig.Visible='on';
        end
        
        function srdropdown_change(this,evt)
            if(this.srdropdown.Value==1)
                this.customfield.Enable='on';
            else
               this.customfield.Enable='off'; 
            end
            
        end
        
        function custom_textentered(this,evt)
            d= str2double(this.customfield.String);
            if isnan(d)
               this.customfield.BackgroundColor=[1,0.8,0.8]; 
            else
                this.customfield.BackgroundColor=[1,1,1];
            end
        end
        
        function startend_textentered(this,evt,field)
            if this.gui.is_timestamp(field.String)
               field.BackgroundColor=[1,1,1]; 
            else
               field.BackgroundColor=[1,0.8,0.8]; 
            end
        end
        
        
        function okpressed(this,~)
           attrpath = this.attrpaths{this.datadropdown.Value};
           startstr = this.startfield.String;
           endstr = this.endfield.String;
           if ~this.gui.is_timestamp(startstr)||~this.gui.is_timestamp(endstr)
              return; 
           end
           if this.srdropdown.Value==1
              sr = str2double(this.customfield.String);
              if ~isnan(sr)
                  this.gui.load_data(attrpath,true,sr,startstr,endstr);
                  close(this.fig);
              end
           else
               sr = this.attrpaths{this.srdropdown.Value-1};
               close(this.fig);
               this.gui.load_data(attrpath,false,sr,startstr,endstr);
           end
        end
        
        function resize(this,~)
            this.ww = this.fig.Position(3);
            this.wh = this.fig.Position(4);
            w=this.ww;
            h=this.wh;
            
            %datadropdownlabel
            dddlx = 0+20;
            dddly = 20;
            dddlw = 80;
            dddlh = 22;
            this.set_pos(this.dddlabel,dddlx,dddly,dddlw,dddlh);
            
            %datadropdown
            dddx = dddlx+dddlw+20;
            dddy = 20;
            dddw = w-dddx-20;
            dddh = 22;
            this.set_pos(this.datadropdown,dddx,dddy,dddw,dddh);
            
            %srdropdownlabel
            sddlx = 0+20;
            sddly = dddy+dddh+20;
            sddlw = 80;
            sddlh = 22;
            this.set_pos(this.sddlabel,sddlx,sddly,sddlw,sddlh);
            
            %srdropdown
            sddx = sddlx+sddlw+20;
            sddy = dddy+dddh+20;
            sddw = w-sddx-20;
            sddh = 22;
            this.set_pos(this.srdropdown,sddx,sddy,sddw,sddh);
            
            %customfieldlabel
            cflx = sddx;
            cfly = sddy+sddh+15;
            cflw = this.customlabel.Position(3);
            cflh = this.customlabel.Position(4);
            this.set_pos(this.customlabel,cflx,cfly,cflw,cflh);
            
            %customfield
            cfx = cflx+cflw+10;
            cfy = cfly;
            cfw = w-cfx-20;
            cfh = cflh;
            this.set_pos(this.customfield,cfx,cfy,cfw,cfh);
            
            %startfield
            sfx = 20;
            sfy = cfly+cflh+15;
            sfw = w/2-10-20;
            sfh = this.startfield.Position(4);
            this.set_pos(this.startfield,sfx,sfy,sfw,sfh);
            
            %endfield
            efx = w/2+10;
            efy = sfy;
            efw = w/2-10-20;
            efh = this.endfield.Position(4);
            this.set_pos(this.endfield,efx,efy,efw,efh);
        end
        
        function set_pos(this,control,x,y,w,h)
            control.Position = [x,this.wh-y-h,w,h];
        end
        
    end
end

