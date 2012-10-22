function varargout = cps_gui(varargin)
% CPS_GUI M-file for cps_gui.fig
%      CPS_GUI, by itself, creates a new CPS_GUI or raises the existing
%      singleton*.
%
%      H = CPS_GUI returns the handle to a new CPS_GUI or the handle to
%      the existing singleton*.
%
%      CPS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CPS_GUI.M with the given input arguments.
%
%      CPS_GUI('Property','Value',...) creates a new CPS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cps_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cps_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cps_gui

% Last Modified by GUIDE v2.5 01-Apr-2011 20:57:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cps_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @cps_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cps_gui is made visible.
function cps_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cps_gui (see VARARGIN)

% Choose default command line output for cps_gui
handles.output = hObject;
s = serial('COM3','baudrate',115200);
set(s,'InputBufferSize',100);
handles.s = s;
handles.s.BytesAvailableFcnCount = 100;
handles.s.BytesAvailableFcnMode = 'byte';
%handles.s.TimerFcn={@serial_callback,handles};
%handles.s.TimerPeriod=.05;
handles.ECUs(1).ECU_ID=2;
handles.ECUs.tasks=0;
handles.ECUs.type_act=1;
for i=1:4
handles.ECUs.action(i)=0;
end
handles.No_of_ECUs=1;
handles.KI=0;
handles.KP=0;
handles.delay = 0;
handles.noise = 0;
global data_returned;
data_returned.tasknum = 0;
data_returned.action = 0;
data_returned.exceed = 0;
handles.s.BytesAvailableFcn = {@serial_callback,handles};
fopen(handles.s);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cps_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cps_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on slider movement.
function KI_sldr_Callback(hObject, eventdata, handles)
% hObject    handle to KI_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.KI=get(hObject,'Value');
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function KI_sldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KI_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function KP_sldr_Callback(hObject, eventdata, handles)
% hObject    handle to KP_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.KP=get(hObject,'Value');
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function KP_sldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KP_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function delay_ms_Callback(hObject, eventdata, handles)
% hObject    handle to delay_ms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.delay=get(hObject,'Value');
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function delay_ms_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay_ms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sensor_noise_db_Callback(hObject, eventdata, handles)
% hObject    handle to sensor_noise_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.noise=get(hObject,'Value');
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sensor_noise_db_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensor_noise_db (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in run_org_cc.
function run_org_cc_Callback(hObject, eventdata, handles)
% hObject    handle to run_org_cc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.run_org_cc, 'Enable', 'off');
%fopen(handles.s);
protocol_ver=1;
j=2;
handles.ECUs.type_act=1;
data=[uint8(handles.ECUs.type_act)];
handles.ECUs(handles.No_of_ECUs).tasks = uint8(bin2dec('00000011'));
handles.ECUs(handles.No_of_ECUs).action(1)= uint8(bin2dec('00010010'));
handles.ECUs(handles.No_of_ECUs).action(2)= uint8(bin2dec('00000000'));
handles.ECUs(handles.No_of_ECUs).action(3)= uint8(bin2dec('00000000'));
handles.ECUs(handles.No_of_ECUs).action(4)= uint8(bin2dec('00000000'));
for i=1:handles.No_of_ECUs
    
    data(j)=uint8(handles.ECUs(i).ECU_ID);
    j=j+1;
    data(j)=uint8(handles.ECUs(i).tasks);
    j=j+1;
    for k=1:length(handles.ECUs(i).action)
        data(j)=uint8(handles.ECUs(i).action(k));
        j=j+1;
    end
end
packet=[uint8(85) uint8(204) length(data)+1 uint8(protocol_ver) data];%length(data)+1--> +1 for protocol version bit
checksum=0;
for i=1:length(packet)
    checksum=bitxor(checksum,packet(i));
end
packet=[packet uint8(checksum)]
t=1;
fwrite(handles.s,packet,'uchar');
set(handles.run_org_cc, 'Enable', 'off');
pause(2);
%fclose(handles.s);
set(handles.run_org_cc, 'Enable', 'on');
checksum=0;


% --- Executes on button press in update_report.
function update_report_Callback(hObject, eventdata, handles)
% hObject    handle to update_report (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data_returned;
if(data_returned.tasknum == 1)
    set(handles.cond_report, 'String', 'Normal Cruise Control Running');
elseif(data_returned.tasknum == 2)
    set(handles.cond_report, 'String', 'Buggy Cruise Control Running');
end

% --- Executes on button press in update_param.
function update_param_Callback(hObject, eventdata, handles)
% hObject    handle to update_param (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.update_param, 'Enable', 'off');
%fopen(handles.s);
protocol_ver=1;
j=2;
handles.ECUs.type_act=2;
data=[uint8(handles.ECUs.type_act)];
handles.ECUs(handles.No_of_ECUs).tasks= uint8(bin2dec('00000010'));
handles.ECUs(handles.No_of_ECUs).action(1)= uint8(handles.KP);
handles.ECUs(handles.No_of_ECUs).action(2)= uint8(handles.KI);
handles.ECUs(handles.No_of_ECUs).action(3)= uint8(handles.delay);
handles.ECUs(handles.No_of_ECUs).action(4)= uint8(handles.noise);
for i=1:handles.No_of_ECUs
    
    data(j)=uint8(handles.ECUs(i).ECU_ID);
    j=j+1;
    data(j)=uint8(handles.ECUs(i).tasks);
    j=j+1;
    for k=1:length(handles.ECUs(i).action)
        data(j)=uint8(handles.ECUs(i).action(k));
        j=j+1;
    end
end
packet=[uint8(85) uint8(204) length(data)+1 uint8(protocol_ver) data];%length(data)+1--> +1 for protocol version bit
checksum=0;
for i=1:length(packet)
    checksum=bitxor(checksum,packet(i));
end
packet=[packet uint8(checksum)]
t=1;
fwrite(handles.s,packet,'uchar');
set(handles.update_param, 'Enable', 'off');
pause(2);
%fclose(handles.s);
set(handles.update_param, 'Enable', 'on');
checksum=0;


% --- Executes on button press in run_bug_cc.
function run_bug_cc_Callback(hObject, eventdata, handles)
% hObject    handle to run_bug_cc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to run_org_cc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.run_bug_cc, 'Enable', 'off');
%fopen(handles.s);
protocol_ver=1;
j=2;
handles.ECUs.type_act=1;
data=[uint8(handles.ECUs.type_act)];
handles.ECUs(handles.No_of_ECUs).tasks= uint8(bin2dec('00000011'));
handles.ECUs(handles.No_of_ECUs).action(1)= uint8(bin2dec('00100001'));
handles.ECUs(handles.No_of_ECUs).action(2)= uint8(bin2dec('00000000'));
handles.ECUs(handles.No_of_ECUs).action(3)= uint8(bin2dec('00000000'));
handles.ECUs(handles.No_of_ECUs).action(4)= uint8(bin2dec('00000000'));
for i=1:handles.No_of_ECUs
    
    data(j)=uint8(handles.ECUs(i).ECU_ID);
    j=j+1;
    data(j)=uint8(handles.ECUs(i).tasks);
    j=j+1;
    for k=1:length(handles.ECUs(i).action)
        data(j)=uint8(handles.ECUs(i).action(k));
        j=j+1;
    end
end
packet=[uint8(85) uint8(204) length(data)+1 uint8(protocol_ver) data];%length(data)+1--> +1 for protocol version bit
checksum=0;
for i=1:length(packet)
    checksum=bitxor(checksum,packet(i));
end
packet=[packet uint8(checksum)]
t=1;
fwrite(handles.s,packet,'uchar');
set(handles.run_bug_cc, 'Enable', 'off');
pause(2);
%fclose(handles.s);
set(handles.run_bug_cc, 'Enable', 'on');
checksum=0;


function serial_callback(Object,eventdata,handles)
 %set(handles.text3,'String','a');
 persistent count;
 persistent act_speed;
 persistent des_speed;
 persistent act_plot_handle;
 persistent des_plot_handle;
 persistent rl_ws_handle;
 persistent rr_ws_handle;
 persistent rl_bf_handle;
 persistent rr_bf_handle;
 persistent yaw_handle;
 persistent accel_handle;
 persistent gear_handle;
 persistent enginerpm_handle;
 persistent rl_ws;
 persistent rr_ws;
 persistent rl_bf;
 persistent rr_bf;
 persistent yaw;
 persistent accel;
 global start;
 global data_returned;
 
if(isempty(act_plot_handle))
     
     count = 200;
     rl_ws = zeros(2000,1);
     rr_ws = zeros(2000,1);
     rl_bf = zeros(2000,1);
     rr_bf = zeros(2000,1);
     yaw = zeros(2000,1);
     accel = zeros(2000,1);
     act_speed = zeros(2000,1);
     des_speed = ones(2000,1);
     
     act_plot_handle = plot(handles.car_speed,linspace(0,200,200),act_speed(count-199:count),'r');
     title(handles.car_speed,'CAR SPEED');
     hold
     des_plot_handle = plot(handles.car_speed,des_speed(1:200));
     ylim(handles.car_speed,[0 100]);
     
     rl_ws_handle = plot(handles.wheel_left,linspace(0,200,200),act_speed(count-199:count),'r');
     title(handles.wheel_left,'Rear Left Wheel');
     hold
     rl_bf_handle = plot(handles.wheel_left,des_speed(1:200));
     ylim(handles.wheel_left,[-50 120]);
     
     rr_ws_handle = plot(handles.wheel_right,linspace(0,200,200),act_speed(count-199:count),'r');
     title(handles.wheel_right,'Rear Right Wheel');
     hold
     rr_bf_handle = plot(handles.wheel_right,des_speed(1:200));
     ylim(handles.wheel_right,[-50 120]);
     
     accel_handle = plot(handles.accel,linspace(0,200,200),act_speed(count-199:count),'r');
     title(handles.accel,'Acceleration');
     ylim(handles.accel,[-40 110]);    
    
     yaw_handle = plot(handles.yaw_rate,linspace(0,200,200),act_speed(count-199:count),'r');
     title(handles.yaw_rate,'Yaw Rate');
     ylim(handles.yaw_rate,[-50 50]);
     
     
     start=1;
         
end
 
if(start==1)
 chksum = 0;
 kk = fread(handles.s,100,'uchar');
 state = 0;
 
 for i = 1:100
    k = kk(i);
    
    if(state==0)
         if(k==uint8(85)) %0x55
             state=1;
             chksum = 0;
             continue
         end
    end
  
  
    if(state==1)
          if(k==204) %cc
              %startcount = startcount + 1;
              state=2;
              chksum = bitxor(85,204);
              continue
          end
    end
  
    if(state>=2)

     state = state + 1;
         if(state<23)
          chksum = bitxor(k,chksum);
         end
         if(state==3)
             
             act_speed(count) = typecast(uint8(k),'int8');
             continue
             elseif(state==4)
             enginerpmh = k;
             continue
         elseif(state==5)
             enginerpm(count) = (256 * enginerpmh + k) * 60/(2*pi);
             continue
         elseif(state==6)
             fl_ws(count) = typecast(uint8(k),'int8') - act_speed(count);
             continue
         elseif(state==7)
             fr_ws(count) = typecast(uint8(k),'int8') - act_speed(count);
             continue
         elseif(state==8)
             rl_ws(count) = typecast(uint8(k),'int8') - act_speed(count);
             continue
         elseif(state==9)
             rr_ws(count) = typecast(uint8(k),'int8') - act_speed(count);
             continue
         elseif(state==10)
             yaw(count) = typecast(uint8(k),'int8');
             continue
             
         elseif(state==11)
             fl_bf(count) = k;
             continue
        elseif(state==12)
             fr_bf(count) = k;
             continue
        elseif(state==13)
             rl_bf(count) = k;
             continue
        elseif(state==14)
             rr_bf(count) = k;
             continue

        elseif(state==15)
             accel(count) = k;
             continue
         elseif(state==16)
             gear = typecast(uint8(k),'int8');
             continue
         elseif(state==17)
             accelcorr = k;
             continue
             
         
         elseif(state==18)
             data_returned.tasknum = uint8(k);
             continue
         elseif(state==19)
             data_returned.action = uint8(k);
             continue
             
         elseif(state==20)
             data_returned.exceed = typecast(uint8(k),'int8');
             continue
         elseif(state==21)
             handles.delay = uint8(k);
             continue
                 
         elseif(state==22)
             des_speed(count) = typecast(uint8(k),'int8');
             continue
                 
                 
         elseif(state==23)    
             if(chksum == uint8(k))
                 set(handles.error_msg, 'String', strcat('Overshoot is above 10% of desired speed by ',int2str(data_returned.exceed)));
                 set(act_plot_handle,'ydata',act_speed(count-199:count));
                 set(des_plot_handle,'ydata',des_speed(count-199:count));
                 set(rl_ws_handle,'ydata',rl_ws(count-199:count));
                 set(rr_ws_handle,'ydata',rr_ws(count-199:count));
                 set(rl_bf_handle,'ydata',rl_bf(count-199:count));
                 set(rr_bf_handle,'ydata',rr_bf(count-199:count));
                 set(yaw_handle,'ydata',yaw(count-199:count));
                 set(accel_handle,'ydata',accel(count-199:count));
                 state=0;
                 count = count + 1;
             continue
             end
             
         end
    end

    if(count>=1600)
        act_speed(1:200)= act_speed(count-199:count);
        des_speed(1:200)= des_speed(count-199:count);
        rl_ws(1:200)= rl_ws(count-199:count);
        rr_ws(1:200)= rr_ws(count-199:count);
        rl_bf(1:200)= rl_bf(count-199:count);
        rr_bf(1:200)= rr_bf(count-199:count);
        accel(1:200)= accel(count-199:count);
        yaw(1:200)= yaw(count-199:count);
        count = 200;
    end
 end
end

    


% --- Executes on button press in close_serial.
function close_serial_Callback(hObject, eventdata, handles)
% hObject    handle to close_serial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fclose(handles.s);
