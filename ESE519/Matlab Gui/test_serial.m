function varargout = test_serial(varargin)
% TEST_SERIAL M-file for test_serial.fig
%      TEST_SERIAL, by itself, creates a new TEST_SERIAL or raises the existing
%      singleton*.
%
%      H = TEST_SERIAL returns the handle to a new TEST_SERIAL or the handle to
%      the existing singleton*.
%
%      TEST_SERIAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_SERIAL.M with the given input
%      arguments.
%
%      TEST_SERIAL('Property','Value',...) creates a new TEST_SERIAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_serial_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to test_serial_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test_serial

% Last Modified by GUIDE v2.5 18-Dec-2010 18:36:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_serial_OpeningFcn, ...
                   'gui_OutputFcn',  @test_serial_OutputFcn, ...
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


% --- Executes just before test_serial is made visible.
function test_serial_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test_serial (see VARARGIN)

% Choose default command line output for test_serial
handles.output = hObject;
% CREATE SERIAL OBJECT and SET CALLBACK FUNC
s = serial('COM4','baudrate',115200);
set(s,'InputBufferSize',100);
handles.s = s;
handles.s.BytesAvailableFcnCount = 100;
handles.s.BytesAvailableFcnMode = 'byte';
handles.cruise_speed = 0;
handles.steering = 00;
handles.accel = 0;
handles.brake = 0;
handles.controls = 00;
handles.act_speed = zeros(1000,1);
handles.stop = 0;
handles.tstart = 0;
handles.elapsed = 0;
handles.s.BytesAvailableFcn = {@instrcallback,handles};
fopen(handles.s);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test_serial wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = test_serial_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)

% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.accel = get(hObject,'Value');
handles.brake = 0;
array1 = [170,204,handles.accel,0,handles.steering,01,00,handles.controls,0];

sendpacket(array1,handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function instrcallback(hObject,eventdata,handles)
 %set(handles.text3,'String','a');
 persistent count;
 persistent act_speed;
 persistent des_speed;
 persistent act_speed_handle;
 persistent des_speed_handle;
 persistent fl_ws_handle;
 persistent fr_ws_handle;
 persistent rl_ws_handle;
 persistent rr_ws_handle;
 persistent fl_bf_handle;
 persistent fr_bf_handle;
 persistent rl_bf_handle;
 persistent rr_bf_handle;
 persistent yaw_handle;
 persistent accel_handle;
 persistent gear_handle;
 persistent accelcorr_handle;
 persistent enginerpm;
 persistent enginerpmh;
 persistent enginerpm_handle;
 persistent fl_ws;
 persistent fr_ws;
 persistent rl_ws;
 persistent rr_ws;
 persistent fl_bf;
 persistent fr_bf;
 persistent rl_bf;
 persistent rr_bf;
 persistent yaw;
 persistent accel;
 persistent gear;
 persistent accelcorr;
 persistent pushbut;
 persistent startcount;
 persistent matchcount;
 persistent tstart;
 persistent tstartchksum ;
 persistent tstop;

 if(isempty(count))
     
     count = 200;
     startcount = 0;
     matchcount = 0;
     tstart = tic;
     tstartchksum = tic;
     act_speed = zeros(2000,1);
     fl_ws = zeros(2000,1);
     fr_ws = zeros(2000,1);
     rl_ws = zeros(2000,1);
     rr_ws = zeros(2000,1);
     fl_bf = zeros(2000,1);
     fr_bf = zeros(2000,1);
     rl_bf = zeros(2000,1);
     rr_bf = zeros(2000,1);
     yaw = zeros(2000,1);
     accel = zeros(2000,1);
     gear = zeros(2000,1);
     accelcorr = zeros(2000,1);
     enginerpm = zeros(2000,1);
     des_speed = ones(200,1);
     figure
     act_speed 
     subplot(2,1,1);act_speed_handle = plot(linspace(0,200,200),act_speed(count-199:count),'r');title('CAR SPEED')
     hold
     des_speed_handle = plot(des_speed(1:200));
     ylim([-50 100])
     subplot(2,1,2); [haxes,hline1,hline2] =  plotyy(linspace(0,200,200),linspace(0,20000,200),linspace(0,200,200),linspace(-1,8,200),'plot');
     title('Engine RPM & Gear ');
     enginerpm_handle = hline1;
     gear_handle = hline2;
     axes(haxes(1))
     ylabel('Engine RPM')
     
     axes(haxes(2))
     
     ylabel('Gear')
      
          
     newfig = figure
         
     h1 = subplot(2,3,1); fl_ws_handle = plot(act_speed(count-199:count)); title('Front Left Wheel');
     hold
     fl_bf_handle = plot(act_speed(count-199:count),'r');ylim([-50 120])
      sprintf('front left')
     curr = get(h1,'Position')
     curr(1) = 0.03;
     curr(2) = 0.61;
     curr(3) = curr(3) * 1.4; % scale width
     set(h1,'Position',curr);
     
     h5 = subplot(2,3,2);yaw_handle = plot(act_speed(count-199:count)); title('Yaw Rate');
      sprintf('yaw rate')
     curr = get(h5,'Position')
     
     curr(1) = 0.39; 
     set(h5,'Position',curr);ylim([-50 50]);
     
     h2 = subplot(2,3,3); fr_ws_handle = plot(act_speed(count-199:count)); title('Front Right Wheel');
     hold
     fr_bf_handle = plot(act_speed(count-199:count),'r');ylim([-50 120])
     sprintf('Front Right')
     curr = get(h2,'Position')
     curr(1) = 0.64; 
     curr(2) = 0.61;
     curr(3) = curr(3) * 1.4; % scale width
     
     set(h2,'Position',curr);
     
     h3 = subplot(2,3,4);rl_ws_handle = plot(act_speed(count-199:count)); title('Rear Left Wheel');
     hold
     rl_bf_handle = plot(act_speed(count-199:count),'r');ylim([-50 120])
     sprintf('Rear Left')
     curr = get(h3,'Position')
     curr(1) = 0.03; 
     curr(2) = 0.09;
     curr(3) = curr(3) * 1.4; % scale width
     set(h3,'Position',curr);
     legend(h3,'Wheel Slip','Brake Pressure','Location',[0.85    0.47    0.1  0.1]);
     
     h6 = subplot(2,3,5);accel_handle = plot(act_speed(count-199:count),'g'); ylim([-40 110]);title('Acceleration');
     hold
     %accecorr_handle = plot(act_speed(count-199:count),'w');ylim([-40
     %110]);
     legend(h6,'Acceleration','Location',[0.51    0.11    0.1  0.1]);
     sprintf('acceleration')
     
     curr = get(h6,'Position')
     curr(1) = 0.39;
     %curr(1) = 0.61; 
     set(h6,'Position',curr);
     
     h4 = subplot(2,3,6);rr_ws_handle = plot(act_speed(count-199:count)); title('Rear Right Wheel');
     hold
     rr_bf_handle = plot(act_speed(count-199:count),'r');ylim([-50 120]);
     sprintf('rear right')
     curr = get(h4,'Position')
     curr(1) = 0.64; 
     curr(2) = 0.09;
     curr(3) = curr(3) * 1.4; % scale width
     set(h4,'Position',curr);
     legend(h4,'Wheel Slip','Brake Pressure','Location',[0.15    0.47    0.1  0.1]);
     
     
     
    
     
     pushbut = uicontrol(newfig,'Style', 'togglebutton', 'String', 'Pause','Position', [20 20 50 20]);
          
     
 end
 des_speed = (get(handles.slider1,'Value')) * ones(200,1);

 %sprintf('Bytesavailable % d ',handles.s.Bytesavailable)
 
 chksum = 0;
kk = fread(handles.s,100,'uchar');
 state = 0;
 
 
 for i = 1:100
 %sprintf('%s',dec2hex(kk(i)))
 k = kk(i);
 
 
if(state==0)
    
    
     if(k==170) %0xaa
         
         state=1;
         chksum = 0;
         continue
     end
    
end
  
  
  if(state==1)
      if(k==204) %cc
         %  sprintf('start')
          startcount = startcount + 1;
          state=2;
          chksum = bitxor(170,204);
          %sprintf('Elapsed time is :')
          %elapsed = toc(tstart)
          %tstart = tic;
          continue
      end
  end
  
 if(state>=2)
    
     state = state + 1;
     if(state<21)
      chksum = bitxor(k,chksum);
     end
     %sprintf('checksum is %s',dec2hex(chksum))
     %sprintf('start the packet')
     if(state==3)
         act_speed(count) = typecast(uint8(k),'int8');
         continue
     elseif(state==4)
         enginerpmh = k;
         %sprintf('engine rpm high %s',dec2hex(k))
         continue
     elseif(state==5)
         enginerpm(count) = (256 * enginerpmh + k) * 60/(2*pi);
         %sprintf('engine rpm low %s',dec2hex(k))
         %sprintf('engine rpm %d',enginerpm(count))
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
         gear(count) = typecast(uint8(k),'int8');
         continue
     elseif(state==18)
         accelcorr(count) = k;
         continue
         
     elseif(state==21)
         state = 0;
         
        if(chksum == k && get(pushbut,'Value')==0 )
          
         
%          matchcount = matchcount + 1;
%          sprintf('match  is  %d' , matchcount)
%          sprintf('Ealpsed chksum time is ')
%          elapsed = toc(tstartchksum)
%          tstartchksum = tic;
         set(act_speed_handle,'ydata',act_speed(count-199:count));
         set(des_speed_handle,'ydata',des_speed(1:200));
         set(enginerpm_handle,'ydata',enginerpm(count-199:count));
         set(gear_handle,'ydata',gear(count-199:count));
         set(fl_ws_handle,'ydata',fl_ws(count-199:count));
         set(fr_ws_handle,'ydata',fr_ws(count-199:count));
         set(rl_ws_handle,'ydata',rl_ws(count-199:count));
         set(rr_ws_handle,'ydata',rr_ws(count-199:count));
         set(fl_bf_handle,'ydata',fl_bf(count-199:count));
         set(fr_bf_handle,'ydata',fr_bf(count-199:count));
         set(rl_bf_handle,'ydata',rl_bf(count-199:count));
         set(rr_bf_handle,'ydata',rr_bf(count-199:count));
         set(yaw_handle,'ydata',yaw(count-199:count));
         set(accel_handle,'ydata',accel(count-199:count));
         
         %set(accelcorr_handle,'ydata',accelcorr(count-199:count));
         
         count = count + 1;
         end
         
         %sprintf('got the packet')
     end
 end     
  
 if(count>=1600)
      sprintf('% number of START bytes received  :  %d',startcount)
      sprintf('% number of MATCH bytes received  :  %d',matchcount)
      act_speed(1:200)= act_speed(count-199:count);
      fl_ws(1:200)= fl_ws(count-199:count);
      fr_ws(1:200)= fr_ws(count-199:count);
      rl_ws(1:200)= rl_ws(count-199:count);
      rr_ws(1:200)= rr_ws(count-199:count);
      fl_bf(1:200)= fl_bf(count-199:count);
      fr_bf(1:200)= fr_bf(count-199:count);
      rl_bf(1:200)= rl_bf(count-199:count);
      rr_bf(1:200)= rr_bf(count-199:count);
      accel(1:200)= accel(count-199:count);
      yaw(1:200)= yaw(count-199:count);
      gear(1:200)= gear(count-199:count);
      accelcorr(1:200)= accelcorr(count-199:count);
      enginerpm(1:200)= enginerpm(count-199:count);
      count = 200;
  end
 
 end  
  
%  kk = num2str(k);
%  set(handles.text3,'String',kk);

 

 
 %sprintf('Hey there');
%guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fclose(handles.s);
close all force



% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.steering = get(hObject,'Value');
array1 = [170,204,handles.accel,handles.brake,handles.steering,01,00,handles.controls,0];

sendpacket(array1,handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1
handles.controls = bitset(handles.controls, 3, get(hObject,'Value'));

array1 = [170,204,handles.accel,handles.brake,handles.steering,01,00,handles.controls,0];

sendpacket(array1,handles);
guidata(hObject, handles);



% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2
handles.controls = bitset(handles.controls, 2, get(hObject,'Value'));

array1 = [170,204,handles.accel,handles.brake,handles.steering,01,00,handles.controls,0];

sendpacket(array1,handles);

guidata(hObject, handles);



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.brake = 100;
handles.controls = bitset(handles.controls, 1, 0);
set(handles.togglebutton3,'Value',0);
array1 = [170,204,0,handles.brake,handles.steering,01,00,handles.controls,0];

sendpacket(array1,handles);

guidata(hObject, handles);

% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton3

handles.controls = bitset(handles.controls, 1, get(hObject,'Value'));

array1 = [170,204,handles.accel,handles.brake,handles.steering,01,00,handles.controls,0];

sendpacket(array1,handles);

guidata(hObject, handles);

function sendpacket(array1,handles)
chksum = 0;
for i = 1:size(array1,2)-1
    tmp = array1(i);
    if(tmp<0)
        tmp = typecast(int8(tmp),'uint8');
        array1(i) = tmp;
    end
    try
    chksum = bitxor(chksum,tmp);
    catch ME
        sprintf(' tmp is %d',tmp)
        sprintf(' chksum is %d',chksum)
    end
        
    %sprintf('chksum is %d',chksum)
end
array1(size(array1,2)) = chksum;

fwrite(handles.s,array1,'uchar');





