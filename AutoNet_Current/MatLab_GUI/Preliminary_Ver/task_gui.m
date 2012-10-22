
function varargout = task_gui(varargin)
%TASK_GUI M-file for task_gui.fig
%      TASK_GUI, by itself, creates a new TASK_GUI or raises the existing
%      singleton*.
%
%      H = TASK_GUI returns the handle to a new TASK_GUI or the handle to
%      the existing singleton*.
%
%      TASK_GUI('Property','Value',...) creates a new TASK_GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to task_gui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      TASK_GUI('CALLBACK') and TASK_GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in TASK_GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help task_gui

% Last Modified by GUIDE v2.5 02-Mar-2011 19:55:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @task_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @task_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before task_gui is made visible.
function task_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for task_gui
handles.output = hObject;
s = serial('COM3','baudrate',115200);
set(s,'InputBufferSize',100);
handles.s = s;
handles.s.BytesAvailableFcnCount = 100;
handles.s.BytesAvailableFcnMode = 'byte';
handles.ECUs(1).ECU_ID=1;
handles.ECUs.tasks=0;
handles.ECUs.type_act=1;
for i=1:4
handles.ECUs.action(i)=0;
end
handles.No_of_ECUs=1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes task_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = task_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected object is changed in task_manip.
function task_manip_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in task_manip 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in manip_task1.
function manip_task1_Callback(hObject, eventdata, handles)
% hObject    handle to manip_task1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1) 
    set(handles.task1_actions, 'Enable', 'on');
    handles.ECUs(handles.No_of_ECUs).tasks= bitor(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('00000001')));
else
    set(handles.task1_actions, 'Enable', 'off');    
    handles.ECUs(handles.No_of_ECUs).tasks= bitand(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('11111110')));
end
% Hint: get(hObject,'Value') returns toggle state of manip_task1
guidata(hObject, handles); 

% --- Executes on button press in manip_task2.
function manip_task2_Callback(hObject, eventdata, handles)
% hObject    handle to manip_task2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1) 
    set(handles.task2_actions, 'Enable', 'on');
    handles.ECUs(handles.No_of_ECUs).tasks= bitor(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('00000010')));
else
    set(handles.task2_actions, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).tasks= bitand(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('11111101')));
end
% Hint: get(hObject,'Value') returns toggle state of manip_task2
guidata(hObject, handles); 

% --- Executes on button press in manip_task3.
function manip_task3_Callback(hObject, eventdata, handles)
% hObject    handle to manip_task3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1) 
    set(handles.task3_actions, 'Enable', 'on');
    handles.ECUs(handles.No_of_ECUs).tasks= bitor(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('00000100')));
else
    set(handles.task3_actions, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).tasks= bitand(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('11111011')));
end
% Hint: get(hObject,'Value') returns toggle state of manip_task3
guidata(hObject, handles); 

% --- Executes on button press in manip_task4.
function manip_task4_Callback(hObject, eventdata, handles)
% hObject    handle to manip_task4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1) 
    set(handles.task4_actions, 'Enable', 'on');
    handles.ECUs(handles.No_of_ECUs).tasks= bitor(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('00001000')));
else
    set(handles.task4_actions, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).tasks= bitand(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('11110111')));
end    
% Hint: get(hObject,'Value') returns toggle state of manip_task4
guidata(hObject, handles); 

% --- Executes on button press in manip_task5.
function manip_task5_Callback(hObject, eventdata, handles)
% hObject    handle to manip_task5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1) 
    set(handles.task5_actions, 'Enable', 'on');
    handles.ECUs(handles.No_of_ECUs).tasks= bitor(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('00010000')));
else
    set(handles.task5_actions, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).tasks= bitand(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('11101111')));
end    
% Hint: get(hObject,'Value') returns toggle state of manip_task5
guidata(hObject, handles); 


% --- Executes on button press in manip_task6.
function manip_task6_Callback(hObject, eventdata, handles)
% hObject    handle to manip_task6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1) 
    set(handles.task6_actions, 'Enable', 'on');
    handles.ECUs(handles.No_of_ECUs).tasks= bitor(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('00100000')));
else
    set(handles.task6_actions, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).tasks= bitand(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('11011111')));
end
% Hint: get(hObject,'Value') returns toggle state of manip_task6
guidata(hObject, handles); 


% --- Executes on button press in manip_task7.
function manip_task7_Callback(hObject, eventdata, handles)
% hObject    handle to manip_task7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1) 
    set(handles.task7_actions, 'Enable', 'on');
    handles.ECUs(handles.No_of_ECUs).tasks= bitor(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('01000000')));
else
    set(handles.task7_actions, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).tasks= bitand(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('10111111')));
end
% Hint: get(hObject,'Value') returns toggle state of manip_task7
guidata(hObject, handles); 


% --- Executes on button press in manip_task8.
function manip_task8_Callback(hObject, eventdata, handles)
% hObject    handle to manip_task8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1) 
    set(handles.task8_actions, 'Enable', 'on');
    handles.ECUs(handles.No_of_ECUs).tasks= bitor(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('10000000')));
else
    set(handles.task8_actions, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).tasks= bitand(uint8(handles.ECUs(handles.No_of_ECUs).tasks), uint8(bin2dec('01111111')));
end
% Hint: get(hObject,'Value') returns toggle state of manip_task8
guidata(hObject, handles); 



% --- Executes on selection change in task1_actions.
function task1_actions_Callback(hObject, eventdata, handles)
% hObject    handle to task1_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice=get(hObject,'Value');
    switch choice
        case 1
            handles.ECUs(handles.No_of_ECUs).action(1)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('00001111')));
            handles.ECUs(handles.No_of_ECUs).action(1)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('00010000')));            
        case 2
            handles.ECUs(handles.No_of_ECUs).action(1)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('00001111')));
            handles.ECUs(handles.No_of_ECUs).action(1)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('00100000')));
    end
% Hints: contents = get(hObject,'String') returns task1_actions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task1_actions
guidata(hObject, handles); 

% --- Executes during object creation, after setting all properties.
function task1_actions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task1_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in task2_actions.
function task2_actions_Callback(hObject, eventdata, handles)
% hObject    handle to task2_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice=get(hObject,'Value');
    switch choice
        case 1
            handles.ECUs(handles.No_of_ECUs).action(1)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('11110000')));
            handles.ECUs(handles.No_of_ECUs).action(1)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('00000001')));            
        case 2
            handles.ECUs(handles.No_of_ECUs).action(1)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('11110000')));
            handles.ECUs(handles.No_of_ECUs).action(1)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('00000010')));
    end
% Hints: contents = get(hObject,'String') returns task2_actions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task2_actions
guidata(hObject, handles); 

% --- Executes during object creation, after setting all properties.
function task2_actions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task2_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in task3_actions.
function task3_actions_Callback(hObject, eventdata, handles)
% hObject    handle to task3_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice=get(hObject,'Value');
    switch choice
        case 1
            handles.ECUs(handles.No_of_ECUs).action(2)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('00001111')));
            handles.ECUs(handles.No_of_ECUs).action(2)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('00010000')));            
        case 2
            handles.ECUs(handles.No_of_ECUs).action(2)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('00001111')));
            handles.ECUs(handles.No_of_ECUs).action(2)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('00100000')));
    end
% Hints: contents = get(hObject,'String') returns task3_actions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task3_actions
guidata(hObject, handles); 

% --- Executes during object creation, after setting all properties.
function task3_actions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task3_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in task4_actions.
function task4_actions_Callback(hObject, eventdata, handles)
% hObject    handle to task4_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice=get(hObject,'Value');
    switch choice
        case 1
            handles.ECUs(handles.No_of_ECUs).action(2)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('11110000')));
            handles.ECUs(handles.No_of_ECUs).action(2)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('00000001')));            
        case 2
            handles.ECUs(handles.No_of_ECUs).action(2)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('11110000')));
            handles.ECUs(handles.No_of_ECUs).action(2)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('00000010')));
    end
% Hints: contents = get(hObject,'String') returns task4_actions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task4_actions
guidata(hObject, handles); 


% --- Executes during object creation, after setting all properties.
function task4_actions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task4_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in task5_actions.
function task5_actions_Callback(hObject, eventdata, handles)
% hObject    handle to task5_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice=get(hObject,'Value');
    switch choice
        case 1
            handles.ECUs(handles.No_of_ECUs).action(3)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(3)), uint8(bin2dec('00001111')));
            handles.ECUs(handles.No_of_ECUs).action(3)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(3)), uint8(bin2dec('00010000')));            
        case 2
            handles.ECUs(handles.No_of_ECUs).action(3)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(3)), uint8(bin2dec('00001111')));
            handles.ECUs(handles.No_of_ECUs).action(3)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(3)), uint8(bin2dec('00100000')));
    end
% Hints: contents = get(hObject,'String') returns task5_actions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task5_actions
guidata(hObject, handles); 


% --- Executes during object creation, after setting all properties.
function task5_actions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task5_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in task6_actions.
function task6_actions_Callback(hObject, eventdata, handles)
% hObject    handle to task6_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice=get(hObject,'Value');
    switch choice
        case 1
            handles.ECUs(handles.No_of_ECUs).action(3)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(3)), uint8(bin2dec('11110000')));
            handles.ECUs(handles.No_of_ECUs).action(3)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(3)), uint8(bin2dec('00000001')));            
        case 2
            handles.ECUs(handles.No_of_ECUs).action(3)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(3)), uint8(bin2dec('11110000')));
            handles.ECUs(handles.No_of_ECUs).action(3)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(3)), uint8(bin2dec('00000010')));
    end
% Hints: contents = get(hObject,'String') returns task6_actions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task6_actions
guidata(hObject, handles); 


% --- Executes during object creation, after setting all properties.
function task6_actions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task6_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in task7_actions.
function task7_actions_Callback(hObject, eventdata, handles)
% hObject    handle to task7_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice=get(hObject,'Value');
    switch choice
        case 1
            handles.ECUs(handles.No_of_ECUs).action(4)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(4)), uint8(bin2dec('00001111')));
            handles.ECUs(handles.No_of_ECUs).action(4)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(4)), uint8(bin2dec('00010000')));            
        case 2
            handles.ECUs(handles.No_of_ECUs).action(4)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(4)), uint8(bin2dec('00001111')));
            handles.ECUs(handles.No_of_ECUs).action(4)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(4)), uint8(bin2dec('00100000')));
    end
% Hints: contents = get(hObject,'String') returns task7_actions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task7_actions
guidata(hObject, handles); 


% --- Executes during object creation, after setting all properties.
function task7_actions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task7_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in task8_actions.
function task8_actions_Callback(hObject, eventdata, handles)
% hObject    handle to task8_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice=get(hObject,'Value');

switch choice
        case 1
            handles.ECUs(handles.No_of_ECUs).action(4)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(4)), uint8(bin2dec('11110000')));
            handles.ECUs(handles.No_of_ECUs).action(4)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(4)), uint8(bin2dec('00000001')));            
        case 2
            handles.ECUs(handles.No_of_ECUs).action(4)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(4)), uint8(bin2dec('11110000')));
            handles.ECUs(handles.No_of_ECUs).action(4)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(4)), uint8(bin2dec('00000010')));
 end
% Hints: contents = get(hObject,'String') returns task8_actions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task8_actions
guidata(hObject, handles); 


% --- Executes during object creation, after setting all properties.
function task8_actions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task8_actions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.run, 'Enable', 'off');
fopen(handles.s);
protocol_ver=1;
j=2;
data=[uint8(handles.ECUs.type_act)];
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
set(handles.run, 'Enable', 'off');
pause(2);
fclose(handles.s);
set(handles.run, 'Enable', 'on');
checksum=0;






% --- Executes on button press in act_task1.
function act_task1_Callback(hObject, eventdata, handles)
% hObject    handle to manip_task1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1)
set(handles.deact_task1, 'Enable', 'off');
handles.ECUs(handles.No_of_ECUs).action(1)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('00010000')));
else if(get(hObject,'Value')==0) 
        set(handles.deact_task1, 'Enable', 'on');
        handles.ECUs(handles.No_of_ECUs).action(1)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('11101111')));
    end
end
% Hint: get(hObject,'Value') returns toggle state of act_task1
guidata(hObject, handles);

% --- Executes on button press in deact_task1.
function deact_task1_Callback(hObject, eventdata, handles)
% hObject    handle to deact_task1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1)
set(handles.act_task1, 'Enable', 'off');
handles.ECUs(handles.No_of_ECUs).action(1)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('00100000')));
else if(get(hObject,'Value')==0) 
        set(handles.act_task1, 'Enable', 'on');
        handles.ECUs(handles.No_of_ECUs).action(1)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('11011111')));
    end
end
% Hint: get(hObject,'Value') returns toggle state of act_task1
guidata(hObject, handles);

% --- Executes on button press in act_task2.
function act_task2_Callback(hObject, eventdata, handles)
% hObject    handle to act_task2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if(get(hObject,'Value')==1)
    set(handles.deact_task2, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).action(1)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('00000001')));
else if(get(hObject,'Value')==0)  
        set(handles.deact_task2, 'Enable', 'on');
        handles.ECUs(handles.No_of_ECUs).action(1)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('11111110')));   
    end
end
% Hint: get(hObject,'Value') returns toggle state of act_task2
guidata(hObject, handles);

% --- Executes on button press in deact_task2.
function deact_task2_Callback(hObject, eventdata, handles)
% hObject    handle to deact_task2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if(get(hObject,'Value')==1)
    set(handles.act_task2, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).action(1)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('00000010')));
else if(get(hObject,'Value')==0)  
        set(handles.act_task2, 'Enable', 'on');
        handles.ECUs(handles.No_of_ECUs).action(1)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(1)), uint8(bin2dec('11111101')));   
    end
end
% Hint: get(hObject,'Value') returns toggle state of deact_task2
guidata(hObject, handles);

% --- Executes on button press in act_task3.
function act_task3_Callback(hObject, eventdata, handles)
% hObject    handle to act_task3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1)  
    set(handles.deact_task3, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).action(2)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('00010000')));
else if(get(hObject,'Value')==0)  
        set(handles.deact_task3, 'Enable', 'on');
        handles.ECUs(handles.No_of_ECUs).action(2)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('11101111')));   
    end
 end
% Hint: get(hObject,'Value') returns toggle state of act_task3
guidata(hObject, handles);

% --- Executes on button press in deact_task3.
function deact_task3_Callback(hObject, eventdata, handles)
% hObject    handle to deact_task3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1)  
    set(handles.act_task3, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).action(2)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('00100000')));
else if(get(hObject,'Value')==0)  
        set(handles.act_task3, 'Enable', 'on');
        handles.ECUs(handles.No_of_ECUs).action(2)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('11011111')));   
    end
 end
% Hint: get(hObject,'Value') returns toggle state of deact_task3
guidata(hObject, handles);

% --- Executes on button press in act_task4.
function act_task4_Callback(hObject, eventdata, handles)
% hObject    handle to act_task4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if(get(hObject,'Value')==1)  
    set(handles.deact_task4, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).action(2)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('00000001')));
else if(get(hObject,'Value')==0)  
        set(handles.deact_task4, 'Enable', 'on');
        handles.ECUs(handles.No_of_ECUs).action(2)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('11111110')));       end
 end
% Hint: get(hObject,'Value') returns toggle state of act_task4
guidata(hObject, handles);

% --- Executes on button press in deact_task4.
function deact_task4_Callback(hObject, eventdata, handles)
% hObject    handle to deact_task4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value')==1)  
    set(handles.act_task4, 'Enable', 'off');
    handles.ECUs(handles.No_of_ECUs).action(2)= bitor(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('00000010')));
else if(get(hObject,'Value')==0)  
        set(handles.act_task4, 'Enable', 'on');
        handles.ECUs(handles.No_of_ECUs).action(2)= bitand(uint8(handles.ECUs(handles.No_of_ECUs).action(2)), uint8(bin2dec('11111101')));
    end
 end
% Hint: get(hObject,'Value') returns toggle state of act_task4
guidata(hObject, handles);
