function varargout = authenticate(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @authenticate_OpeningFcn, ...
                   'gui_OutputFcn',  @authenticate_OutputFcn, ...
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


% --- Executes just before authenticate is made visible.
function authenticate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for authenticate
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes authenticate wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = authenticate_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function t_f_Callback(hObject, eventdata, handles)
% hObject    handle to t_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_f as text
%        str2double(get(hObject,'String')) returns contents of t_f as a double


% --- Executes during object creation, after setting all properties.
function t_f_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in b_f.
function b_f_Callback(hObject, eventdata, handles)
% hObject    handle to b_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename2, pathname2] = ...
    uigetfile('*.tif;*.jpg','选择指纹图像', ...
    './指纹识别');
set(handles.t_f, 'string', [pathname2 filename2]);

% --- Executes on button press in b_authenticate.
function b_authenticate_Callback(hObject, eventdata, handles)
% hObject    handle to b_authenticate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% read fingerprint for authentication
set(handles.t_header, 'string', '');
set(handles.edit5, 'string','');
drawnow();
path = get(handles.t_f, 'string');
if get(handles.radiobutton1, 'Value') == 0 && get(handles.radiobutton3, 'Value') == 0
age = 2;
elseif get(handles.radiobutton1, 'Value') == 1 && get(handles.radiobutton3, 'Value') == 0
age = 0;
elseif get(handles.radiobutton1, 'Value') == 0 && get(handles.radiobutton3, 'Value') == 1
age = 1;  
end
img1 = imread(path);  %读取图像信息
imshow(img1);title('Input'); %显示图像

set(hObject, 'string', '提取细节特征点...');
drawnow();
inp_minutiae = ext_finger(img1, 1); %调用函数提取特征值


set(hObject, 'string', '对比数据库... ');
drawnow();
load .\database.mat person minutiae0 minutiae1 minutiae2
if age==0
uniq = unique(minutiae0(:, 1)); %读取数据库已提取特征值的图片的唯一ID
r = size(uniq(:, :)); %统计已提取特征值的图片数量
k = size(minutiae0(:, :)); %统计矩阵大小
%矩阵转结构体，结构体转单元数组
uniq = table2struct(uniq);
uniq = struct2cell(uniq);

first = minutiae0(:, 1); %读取所有唯一ID
first = table2struct(first);
first = struct2cell(first);
s = 0;

for i=1:r
    temp_struct = struct('X', [], 'Y', [], 'Type', [], 'Angle', []); %创建临时结构体
    for j=1:k
        % build temporary structure of minutiae pertaining to a fingerprint
        if strcmp(uniq(i), first(j)) %比较唯一ID，确认是否是同一张图片的特征值
            %读取2-5列特征值存储到临时结构体
            p = size(temp_struct);
            if p==0
                temp_struct = table2struct(minutiae0(j, 2:5));
            else
                temp_struct = [temp_struct; table2struct(minutiae0(j, 2:5))];
            end
        end
    end
        
    % 比对得到得分数组
    temp_struct = transpose(cell2mat(struct2cell(temp_struct)));
    if s==0
        s = match(inp_minutiae, temp_struct);
    else
        s = horzcat(s, match(inp_minutiae, temp_struct));
    end
        
end
elseif age==1
uniq = unique(minutiae1(:, 1)); %读取数据库已提取特征值的图片的唯一ID
r = size(uniq(:, :)); %统计已提取特征值的图片数量
k = size(minutiae1(:, :)); %统计矩阵大小
%矩阵转结构体，结构体转单元数组
uniq = table2struct(uniq);
uniq = struct2cell(uniq);

first = minutiae1(:, 1); %读取所有唯一ID
first = table2struct(first);
first = struct2cell(first);
s = 0;

for i=1:r
    temp_struct = struct('X', [], 'Y', [], 'Type', [], 'Angle', []); %创建临时结构体
    for j=1:k
        % build temporary structure of minutiae pertaining to a fingerprint
        if strcmp(uniq(i), first(j)) %比较唯一ID，确认是否是同一张图片的特征值
            %读取2-5列特征值存储到临时结构体
            p = size(temp_struct);
            if p==0
                temp_struct = table2struct(minutiae1(j, 2:5));
            else
                temp_struct = [temp_struct; table2struct(minutiae1(j, 2:5))];
            end
        end
    end
        
    % 比对得到得分数组
    temp_struct = transpose(cell2mat(struct2cell(temp_struct)));
    if s==0
        s = match(inp_minutiae, temp_struct);
    else
        s = horzcat(s, match(inp_minutiae, temp_struct));
    end
        
end
elseif age==2
uniq = unique(minutiae2(:, 1)); %读取数据库已提取特征值的图片的唯一ID
r = size(uniq(:, :)); %统计已提取特征值的图片数量
k = size(minutiae2(:, :)); %统计矩阵大小
%矩阵转结构体，结构体转单元数组
uniq = table2struct(uniq);
uniq = struct2cell(uniq);

first = minutiae2(:, 1); %读取所有唯一ID
first = table2struct(first);
first = struct2cell(first);
s = 0;

for i=1:r
    temp_struct = struct('X', [], 'Y', [], 'Type', [], 'Angle', []); %创建临时结构体
    for j=1:k
        % build temporary structure of minutiae pertaining to a fingerprint
        if strcmp(uniq(i), first(j)) %比较唯一ID，确认是否是同一张图片的特征值
            %读取2-5列特征值存储到临时结构体
            p = size(temp_struct);
            if p==0
                temp_struct = table2struct(minutiae2(j, 2:5));
            else
                temp_struct = [temp_struct; table2struct(minutiae2(j, 2:5))];
            end
        end
    end
        
    % 比对得到得分数组
    temp_struct = transpose(cell2mat(struct2cell(temp_struct)));
    if s==0
        s = match(inp_minutiae, temp_struct);
    else
        s = horzcat(s, match(inp_minutiae, temp_struct));
    end
        
end
end

maxim = max(s); %寻找最大值
len = length(s);
%得到最大值在数组中的位置
for i=1:len
    if s(i)==maxim
        break;
    end
end
 

if (maxim<0.48) 
    set(handles.t_header, 'string', '认证未通过，没有找到指纹.');
    drawnow();
else
    x = round(i/2); %得到图像所属者在person中的位置
    count = x;
    if age==0
    for ii = 1:size(person, 1)
        if table2array(person(ii, 2))==0
            count = count - 1;
            if count == 0
                break;
            end
        end
    end
    elseif age==1
    for ii = 1:size(person, 1)
       if table2array(person(ii, 2))==1
           count = count - 1;
           if count == 0
               break;
           end
       end
    end 
    elseif age==2
        ii = x;
    end
    name = char(struct2cell(table2struct(person(ii, 1))));
    set(handles.t_header, 'string', ['认证通过, 你好 ' name '!']);
    drawnow();
end

set(hObject, 'string', '认证');
set(handles.edit5, 'string', maxim);

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
set(handles.radiobutton1,'value',1)
set(handles.radiobutton3,'value',0)
set(handles.radiobutton5,'value',0)
% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
set(handles.radiobutton1,'value',0)
set(handles.radiobutton3,'value',1)
set(handles.radiobutton5,'value',0)

% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
set(handles.radiobutton1,'value',0)
set(handles.radiobutton3,'value',0)
set(handles.radiobutton5,'value',1)


% --- Executes during object deletion, before destroying properties.
function axes1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
