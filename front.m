function varargout = front(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @front_OpeningFcn, ...
                   'gui_OutputFcn',  @front_OutputFcn, ...
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

% --- Executes just before front is made visible.
function front_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to front (see VARARGIN)

% Choose default command line output for front
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes front wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = front_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in b_enrol.
function b_enrol_Callback(hObject, eventdata, handles)
% hObject    handle to b_enrol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enrol

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in p_authenticate.
function p_authenticate_Callback(hObject, eventdata, handles)
% hObject    handle to p_authenticate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
authenticate


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 获取当前程序所在目录路径
currPath = pwd;

% 删除数据库文件
delete(fullfile(currPath, 'database.mat'));

% 创建数据库文件
fid = fopen(fullfile(currPath, 'database.mat'), 'w');
fclose(fid);

% 保存数据到数据库文件
person = struct('Name', [], 'Age', [], 'FID1', [],'FID2', []);
person = struct2table(person);

minutiae0 = struct('ID', [], 'X', [], 'Y', [], 'Type', [], 'Angle', []);
minutiae0 = struct2table(minutiae0);

minutiae1 = struct('ID', [], 'X', [], 'Y', [], 'Type', [], 'Angle', []);
minutiae1 = struct2table(minutiae1);

minutiae2 = struct('ID', [], 'X', [], 'Y', [], 'Type', [], 'Angle', []);
minutiae2 = struct2table(minutiae2);
save(fullfile(currPath, 'database.mat'), 'person','minutiae0','minutiae1','minutiae2');


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
judge


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
untitled1


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 要删除和重新创建的文件夹路径
% 文件夹路径列表
folderPaths = {'./斗和簸箕\原始图像', './斗和簸箕\增强图像', './斗和簸箕\分类后图像'};

% 遍历每个文件夹
for i = 1:numel(folderPaths)
    folderPath = folderPaths{i};

    % 删除文件夹（如果存在）
    if exist(folderPath, 'dir')
        rmdir(folderPath, 's');
    end

    % 创建新的文件夹
    mkdir(folderPath);
end
