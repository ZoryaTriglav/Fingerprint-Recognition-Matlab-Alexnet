function varargout = judge(varargin)
% JUDGE MATLAB code for judge.fig
%      JUDGE, by itself, creates a new JUDGE or raises the existing
%      singleton*.
%
%      H = JUDGE returns the handle to a new JUDGE or the handle to
%      the existing singleton*.
%
%      JUDGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JUDGE.M with the given input arguments.
%
%      JUDGE('Property','Value',...) creates a new JUDGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before judge_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to judge_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help judge

% Last Modified by GUIDE v2.5 19-May-2023 16:55:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @judge_OpeningFcn, ...
                   'gui_OutputFcn',  @judge_OutputFcn, ...
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


% --- Executes just before judge is made visible.
function judge_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to judge (see VARARGIN)

% Choose default command line output for judge
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes judge wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = judge_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load .\net1.mat
input_folder1 = './斗和簸箕\原始图像';
output_folder1 = './斗和簸箕\增强图像';

% 获取输入文件夹中所有的图像文件名
file_list = dir(fullfile(input_folder1, '*.jpg'));

% 循环处理每个图像文件
for i = 1:length(file_list)
    set(hObject, 'string', ['正在处理第' num2str(i) '张图像']);
    % 读取图像
    drawnow();
    image_path = fullfile(input_folder1, file_list(i).name);
    image = imread(image_path);
    
    % 处理图像（示例：反转图像）
    processed_image =enhance2(image);
    
    % 构造输出文件名
    output_filename = fullfile(output_folder1, ['chose' file_list(i).name]);
    
    % 保存处理后的图像到输出文件夹中
    imwrite(processed_image, output_filename);
end


input_folder = './斗和簸箕\增强图像';
output_folder = './斗和簸箕\分类后图像';
file_list = dir(fullfile(input_folder, '*.jpg'));
a=0;
b=0;

for i = 1:length(file_list)
    % 读取图像
    set(hObject, 'string', ['正在处理第' num2str(i) '张图像']);
    drawnow();
    image_path = fullfile(input_folder, file_list(i).name);
    image = imread(image_path);
    
    % 处理图像（示例：反转图像）
    img = imresize(image, [388 374]);
    img=im2gray(img);
    label = classify(net, img);
    if label=='斗1'
        a=a+1;
        output_filename = fullfile(output_folder, ['斗' file_list(i).name]);
    elseif label== '簸箕1'
        b=b+1;
        output_filename = fullfile(output_folder, ['簸箕' file_list(i).name]);
    end
    imwrite(img, output_filename);
end
    set(hObject, 'string', '分析');
    drawnow();
set(handles.edit1, 'string', ['共有 ' num2str(a) '个斗和' num2str(b) '个簸箕']);
winopen('./斗和簸箕\分类后图像')



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedFolder = uigetdir('选择文件夹');
if selectedFolder == 0
    msgbox('未选择文件夹');
    return;
end

% 指定目标文件夹
targetFolder = './斗和簸箕\原始图像';

% 选择要处理的图像文件
[files, folder] = uigetfile(fullfile(selectedFolder, '*.jpg'), '选择图像文件', 'MultiSelect', 'on');
if isequal(files, 0)
    msgbox('未选择图像文件');
    return;
end

% 如果只选择了一个图像文件，将其转换为单元素的单元格数组
if ~iscell(files)
    files = {files};
end

% 遍历每个选定的图像文件并复制到目标文件夹
for i = 1:numel(files)
    sourceFile = fullfile(folder, files{i});
    targetFile = fullfile(targetFolder, files{i});
    copyfile(sourceFile, targetFile);
end
% 显示选择完成的消息窗口
if numel(files)~= 0
msgbox('选择完成，请点击分析按钮', '提示');
end
