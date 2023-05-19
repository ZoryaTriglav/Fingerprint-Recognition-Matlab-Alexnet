function varargout = enrol(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @enrol_OpeningFcn, ...
                   'gui_OutputFcn',  @enrol_OutputFcn, ...
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

% --- Executes just before enrol is made visible.
function enrol_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to enrol (see VARARGIN)

% Choose default command line output for enrol
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes enrol wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = enrol_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function t_name_Callback(hObject, eventdata, handles)
% hObject    handle to t_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_name as text
%        str2double(get(hObject,'String')) returns contents of t_name as a double


% --- Executes during object creation, after setting all properties.
function t_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in b_enroltodb.
function b_enroltodb_Callback(hObject, eventdata, handles)
% hObject    handle to b_enroltodb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% getting the field values
name = get(handles.t_name, 'string');
if get(handles.radiobutton1, 'Value') == 1 && get(handles.radiobutton2, 'Value') == 0
age = 0;
elseif get(handles.radiobutton1, 'Value') == 0 && get(handles.radiobutton2, 'Value') == 1
age = 1;
end
path1 = get(handles.t_f1, 'string');
path2 = get(handles.edit6, 'string');
set(hObject, 'String', '登记中... ');
drawnow();


load .\database.mat person
load .\database.mat minutiae0
load .\database.mat minutiae1
load .\database.mat minutiae2

%正则表达式提取唯一ID
ind = regexp(path1, '[0-9][0-9][0-9]_[0-9]');
id1 = path1(ind:ind+4);
ind = regexp(path2, '[0-9][0-9][0-9]_[0-9]');
id2 = path2(ind:ind+4);
%构成结构体
rec1 = struct('Name', name, 'Age', age, 'FID1', id1,'FID2', id2);

[r] = size(person); %读取人数
temp_struct = table2struct(person);%创建临时结构体，读取person数据表
%在临时结构体中将两个结构体合并
if r == 0
    temp_struct = rec1;
else
    temp_struct = [temp_struct; rec1];
end

person = struct2table(temp_struct); %将临时结构体转换为数据表


save .\database.mat person minutiae0 minutiae1 minutiae2



set(hObject, 'String', '指纹登记中...');
drawnow();
%提取两张指纹图像特征
if path1~=0
    minu1 = ext_finger(imread(path1));
    minu1 = num2cell(minu1);
    minu1 = struct('ID', id1, 'X', minu1(:, 1), 'Y', minu1(:, 2),...
                   'Type', minu1(:, 3), 'Angle', minu1(:, 4));
end
if path2~=0
    minu2 = ext_finger(imread(path2));
    minu2 = num2cell(minu2);
    minu2 = struct('ID', id2, 'X', minu2(:, 1), 'Y', minu2(:, 2),...
                   'Type', minu2(:, 3), 'Angle', minu2(:, 4));
end
if age == 0
[r] = size(minutiae0);
temp_struct = table2struct(minutiae0);

if r == 0
    temp_struct = [minu1;minu2];
else
    temp_struct = [temp_struct; minu1;minu2];
end

minutiae0 = struct2table(temp_struct);

save .\database.mat person minutiae0 minutiae1 minutiae2
elseif age==1
[r] = size(minutiae1);
temp_struct = table2struct(minutiae1);

if r == 0
    temp_struct = [minu1;minu2];
else
    temp_struct = [temp_struct; minu1;minu2];
end

minutiae1 = struct2table(temp_struct);

save .\database.mat person minutiae0 minutiae1 minutiae2
end

[r] = size(minutiae2);
temp_struct = table2struct(minutiae2);

if r == 0
    temp_struct = [minu1;minu2];
else
    temp_struct = [temp_struct; minu1;minu2];
end

minutiae2 = struct2table(temp_struct);

save .\database.mat person minutiae0 minutiae1 minutiae2

% for clearing the fields
set(handles.t_name, 'string', '');
set(handles.t_f1, 'string', '');
set(handles.edit6, 'string', '');
set(hObject, 'String', '登记');
drawnow();



function t_f1_Callback(hObject, eventdata, handles)
% hObject    handle to t_f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_f1 as text
%        str2double(get(hObject,'String')) returns contents of t_f1 as a double


% --- Executes during object creation, after setting all properties.
function t_f1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in b_f1.
function b_f1_Callback(hObject, eventdata, handles)
% hObject    handle to b_f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename1, pathname1] = ...
    uigetfile('*.tif;*.jpg','选择第一个指纹', ...
    './指纹识别');
set(handles.t_f1, 'string', [pathname1 filename1]);




% --- Executes during object creation, after setting all properties.
function t_f2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function b_f1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to b_f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
set(handles.radiobutton1,'value',1)
set(handles.radiobutton2,'value',0)

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
set(handles.radiobutton1,'value',0)
set(handles.radiobutton2,'value',1)

% --- Executes during object creation, after setting all properties.
function radiobutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename2, pathname2] = ...
    uigetfile('*.tif;*.jpg','选择第二个指纹', ...
    './指纹识别');
set(handles.edit6, 'string', [pathname2 filename2]);
