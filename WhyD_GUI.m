function varargout = WhyD_GUI(varargin)
%% W2MHS_GUI M-file for WhyD_GUI.fig
%
%       W2MHS_GUI, is the GUI for the White Matter Hyperintensity
%       Segmentation and Quantification application created by Vamsi
%       Ithapu.
%
%       Author: Chris Lindner.
%
% Last Modified by Chris Lindner v2.5 25-Feb-2013 16:11:32

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       'WhyD_GUI', ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @WhyD_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @WhyD_GUI_OutputFcn, ...
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

% --- Executes just before WhyD_GUI is made visible.
function WhyD_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for W2MHS_GUI\home\clinder\Desktop\W2MHS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% If defaults ate set, intialize accordingly

display(sprintf('\n   White Matter Hyperintensity Segmentation and Quantification v1.3'));
display('University of Wisconsin - Wisconsin Alzheimers Disease Research Center');
display('Initializing W2MHS........');

path = mfilename('fullpath');  path = strcat(path, '.m');
path = strrep(path, 'WhyD_GUI.m', '');
file = strcat(path ,'/default.mat');
set(hObject, 'Name', 'W2MHS');

axes(handles.pic);
imshow('brain.jpg');
axes(handles.axes2);
imshow('uw.png');

if exist(file)
    try
        load(file);
        set(handles.output_name, 'String', state.output_name);
        set(handles.output_path, 'String', state.output_path);
        setappdata(handles.add_button, 'image', state.image_t1);
        setappdata(handles.add_button, 'image',state.image_t2);
        %   set(handles.output_ids, 'String', state.output_ids);
        set(handles.w2mhs_toolpath, 'String', state.w2mhs_toolpath);
        sPath = size(state.w2mhs_toolpath);
        if sPath(2) == 0, path = mfilename('fullpath');
            path = strcat(path, '.m'); path = strrep(path, 'WhyD_GUI.m', '');
            set(handles.w2mhs_toolpath, 'String', path);  end
        set(handles.spm_tool_path, 'String', state.spm_tool_path);
        set(handles.do_training, 'value', state.do_training);
        set(handles.do_preproc, 'value',state.do_preproc);
        set(handles.do_quantify, 'value', state.do_quantify);
        set(handles.image_list, 'String', state.image_list);
        setappdata(handles.image_list, 'image_matrix', state.image_matrix);
        setappdata(handles.add_button, 'def_path', state.def_path)
        setappdata(handles.image_list, 'id_matrix', state.id_matrix);
        %set(handles.slider1,'value',0.1)
    catch e
        errordlg('Issue loading default configuration.', 'Error');
    end

end

% --- Outputs from this function are returned to the command line.
function varargout = WhyD_GUI_OutputFcn(hObjectmerit_data, eventdata, handles)
varargout{1} = handles.output;

% --- Executes on button press in output_path_button.
function output_path_button_Callback(hObject, eventdata, handles)
file_path = uigetdir(getappdata(hObject, 'path'));
if file_path ~= 0
    set(handles.output_path,'string', file_path);
    setappdata(hObject, 'path', file_path);
end

% --- Executes during object creation, afDebugter setting all properties.
function output_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function output_ids_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in add_button.
function add_button_Callback(hObject, eventdata, handles)

choice = questdlg('What would you like to add?','Add images...','Single Subject', 'Directory', 'Single Subject');

if(strcmp(choice, 'Single Subject'))

    [input_image_t1,path1] = uigetfile({'*.nii'},'Select T1 Image...',getappdata(hObject, 'def_path'));
    file1 = strcat(path1, input_image_t1);
    if path1 ~= 0
        setappdata(hObject, 'def_path', path1);
        setappdata(hObject, 'path1', path1);
        setappdata(hObject, 'path2', path1);

        [input_image_t2, path2] = uigetfile({'*.nii'},'Select T2 Image...',getappdata(hObject, 'path2'));
        setappdata(hObject, 'path2', path2);
        if path2 ~= 0
            file2 = strcat(path2, input_image_t2);
        end


        fNam = lower(input_image_t1);
        l = size(fNam);
        ind = 0;

        for j = 1:l(2)
            char = fNam(j);
            if (char == '0' || char == '1' || char == '2' || char == '3' || ...
                    char == '4' || char == '5' || char == '6' || char == '7' || ...
                    char == '8' || char == '9') && ind == 0
                ind = j;
                break;
            end
        end
        defID = {''};
        if ind ~= 0
            defID{1} = strrep(strrep(strrep(strrep(strrep(lower(fNam(ind:end)),'bravo','')   ...
                ,'flair',''),'__','_'),'.nii',''),' ','');
        end


        id = inputdlg('Enter a subject ID:', 'Specify Identifier...' ,[1 25],defID);

        if path1 == 0
            errordlg('Make sure to select a T1 and T2 Image', 'Error');
        elseif path2 == 0
            errordlg('Make sure to select a T1 and T2 Image', 'Error');
        elseif(numel(id) == 1 )
            tmp = get(handles.image_list, 'String');
            [row, col] = size(tmp);

            spaces = ',';
            if 15 - numel(id{1}) > 0
                for i = 1 : 15 - numel(id{1})
                    spaces = cat(2,spaces, ' ');

                end
            end

            string(1:79) = 'ID:                    T1:                         T2:                         ';
            endInd = 4+numel(id{1})-1;
            if(endInd > 22)
                endInd = 22;
            end
            string(4:endInd) = id{1}(1:endInd-3);

            endInd = 27+numel(input_image_t1)-1;
            if(endInd > 50)
                endInd = 50;
            end
            string(27:endInd) = input_image_t1(1:endInd-26);

            endInd = 56+numel(input_image_t2)-1;
            if(endInd > 79)
                endInd = 79;
            end
            string(56:endInd) = input_image_t2(1:endInd-55);


            tmp{row+1} = string;
            set(handles.image_list, 'String', tmp);

            tmp = getappdata(handles.image_list, 'image_matrix');
            tmp2 = getappdata(handles.image_list, 'id_matrix');

            [row, col] = size(tmp);
            tmp{row+1,1} = file1;       tmp{row+1,2} = file2;
            tmp2{row+1,1} = id{1};

            setappdata(handles.image_list, 'image_matrix', tmp);
            setappdata(handles.image_list, 'id_matrix', tmp2);
            set(handles.image_list, 'Value', row+1);
        end
    end
elseif(strcmp(choice, 'Directory'))
    path = uigetdir(getappdata(hObject, 'def_path'),'Select Batch Directory');
    if path ~= 0
        WhyD_batch(hObject, eventdata, handles, path);
    end

end
% --- Executes on button press in add_button. a single one of those
function remove_Callback(hObject, eventdata, handles)

index = get(handles.image_list, 'Value');
tmp = get(handles.image_list, 'String');
tmpB = getappdata(handles.image_list, 'image_matrix');
tmpC = getappdata(handles.image_list, 'id_matrix');
[row col] = size(tmp);
if (row > 0 && col > 0)
    tmp{index,1} = 0;
    tmp = tmp(cellfun('isclass', tmp(:,1), 'char'),:);

    tmpB{index,1} = 0; tmpB{index,2} = 0;
    tmpB = tmpB(cellfun('isclass', tmpB(:,1), 'char'),:);

    tmpC{index,1} = 0; tmpC{index,2} = 0;
    tmpC = tmpC(cellfun('isclass', tmpC(:,1), 'char'),:);

    set(handles.image_list, 'Value', 1);
    set(handles.image_list, 'String', tmp);

    setappdata(handles.image_list, 'image_matrix', tmpB);
    setappdata(handles.image_list, 'id_matrix', tmpC);
end

% --- Executes during object creation, after seNametting all properties.
function input_method_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in run_button.
function run_button_Callback(hObject, eventdata, handles)

clc

%% Format Arguments

arg0 = {get(handles.output_name, 'String')};
arg1 = {get(handles.output_path, 'String')};
arg2 = getappdata(handles.image_list, 'image_matrix') ; 
arg3 = getappdata(handles.image_list, 'id_matrix');
arg4 = get(handles.w2mhs_toolpath, 'String'); 
arg5 = get(handles.spm_tool_path, 'String');
tmp = get(handles.do_training, 'String'); 
tmp = tmp(get(handles.do_training, 'value'));
arg7 = tmp{1,1}; tmp = get(handles.do_preproc,'String');
tmp = tmp(get(handles.do_preproc, 'value'));
arg8 = tmp{1,1}; tmp = get(handles.do_quantify, 'String'); 
tmp = tmp(get(handles.do_quantify, 'value'));
arg9 = tmp{1,1};

clean_th = str2double(get(handles.edit7, 'String'));
pmap_cut = str2double(get(handles.edit6, 'String'));

if(isnan(clean_th))
    clean_th  = 2.5;
end
if(isnan(pmap_cut))
    pmap_cut  = 0.5;
end
tmp = get(handles.popupmenu5, 'String');
tmp = tmp(get(handles.popupmenu5, 'value'));
delete_preproc = tmp{1,1};

param(clean_th, pmap_cut, delete_preproc);

%% Run WhyD

WhyD_setup(arg0,arg1,arg2,arg3,arg4,arg5,arg7,arg8,arg9,2);

% --- Executes during object creation, after setting all properties.
function do_training_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function do_preproc_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function do_quantify_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function output_path_CreateFcn(hObject, eventdaNameta, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in spm_tool.
function spm_tool_Callback(hObject, eventdata, handles)

file_path = uigetdir(getappdata(hObject, 'path'));
if (file_path ~= 0)
    set(handles.spm_tool_path,'String', file_path);
    setappdata(hObject, 'path', file_path);
end

% --- Executes during object creation, after setting all properties.
function spm_tool_path_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in w2mhs_tool.
function w2mhs_tool_Callback(hObject, eventdata, handles)
file_path = uigetdir(getappdata(hObject, 'path'));
if (file_path ~= 0)
    set(handles.w2mhs_toolpath,'string', file_path);
    setappdata(hObject, 'path', file_path);
end

% --- Executes during object creation, after setting all proWhyD_dataperties.
function w2mhs_toolpath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string',pwd());

function new_Callback(hObject, eventdata, handles)

path = mfilename('fullpath');  path = strcat(path, '.m');
path = strrep(path, 'WhyD_GUI.m', '');
file = strcat(path ,'/default.mat');

if exist(file)
    try
        load(file);
        set(handles.output_name, 'String', state.output_name);
        set(handles.output_path, 'String', state.output_path);
        setappdata(handles.add_button, 'image', state.image_t1);
        setappdata(handles.add_button, 'image',state.image_t2);
        % set(handles.output_ids, 'String', state.output_ids);
        set(handles.w2mhs_toolpath, 'String', state.w2mhs_toolpath);
        sPath = size(state.w2mhs_toolpath);
        if sPath(2) == 0, path = mfilename('fullpath');
            path = strcat(path, '.m'); path = strrep(path, 'WhyD_GUI.m', '');
            set(handles.w2mhs_toolpath, 'String', path);  end
        set(handles.spm_tool_path, 'String', state.spm_tool_path);
        set(handles.do_training, 'value', state.do_training);
        set(handles.do_preproc, 'value',state.do_preproc);
        set(handles.do_quantify, 'value', state.do_quantify);
        set(handles.image_list, 'String', state.image_list);
        setappdata(handles.image_list, 'image_matrix', state.image_matrix);
        setappdata(handles.add_button, 'def_path', state.def_path)
        setappdata(handles.image_list, 'id_matrix', state.id_matrix);
    catch e
        errordlg('Issue loading default configuration', 'Error');
    end

end

function open_Callback(hObject, eventdata, handles)

[FileName,PathName] = uigetfile('.mat','Open file...');
if(numel(FileName) ~= 0 && numel(PathName) ~=0)
    file = strcat(PathName,FileName);
    if exist(file)
        load(file);
        set(handles.output_name, 'String', state.output_name);
        set(handles.output_path, 'String', state.output_path);
        setappdata(handles.add_button, 'image', state.image_t1);
        setappdata(handles.add_button, 'image',state.image_t2);
        %    set(handles.output_ids, 'String', state.output_ids);
        set(handles.w2mhs_toolpath, 'String', state.w2mhs_toolpath);
        set(handles.spm_tool_path, 'String', state.spm_tool_path);
        %   set(handles.input_method, 'value', state.input_method);
        set(handles.do_training, 'value', state.do_training);
        set(handles.do_preproc, 'value',state.do_preproc);
        set(handles.do_quantify, 'value', state.do_quantify);
        set(handles.image_list, 'String', state.image_list);
        setappdata(handles.image_list, 'image_matrix', state.image_matrix);
        setappdata(handles.add_button, 'def_path', state.def_path)
        setappdata(handles.image_list, 'id_matrix', state.id_matrix);
    end
end
function close_Callback(hObject, eventdata, handles)
clc
display('Bye for now...');
delete(handles.figure1)

function save_Callback(hObject, eventdata, handles)

[FileName,PathName] = uiputfile('W2MHS_save.mat','Save as...');

if(numel(FileName ~= 0) && numel(PathName ~=0))
    state.output_name = get(handles.output_name, 'String');
    state.output_path =  get(handles.output_path, 'String');
    state.image_t1 = getappdata(handles.add_button, 'image');
    state.image_t2 = getappdata(handles.add_button, 'image');
    % state.output_ids =  get(handles.output_ids, 'String');
    state.w2mhs_toolpath = get(handles.w2mhs_toolpath, 'String');
    state.spm_tool_path = get(handles.spm_tool_path, 'String');
    %statre.input_method =  get(handles.input_method, 'value');
    state.do_preproc = get(handles.do_preproc, 'value');
    state.do_training = get(handles.do_training, 'value');
    state.do_quantify = get(handles.do_quantify, 'value');
    state.image_list = get(handles.image_list, 'String');
    state.image_matrix = getappdata(handles.image_list, 'image_matrix');
    state.def_path = getappdata(handles.add_button, 'def_path');
    state.id_matrix = getappdata(handles.image_list, 'id_matrix');

    save( strcat(PathName,FileName), 'state');
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

function def_Callback(hObject, eventdata, handles)
path = mfilename('fullpath');  path = strcat(path, '.m');
path = strrep(path, 'WhyD_GUI.m', '');

file = strcat(path ,'/default.mat');

state.output_name = get(handles.output_name, 'String');
state.output_path =  get(handles.output_path, 'String');
state.image_t1 = getappdata(handles.add_button, 'image');
state.image_t2 = getappdata(handles.add_button, 'image');
%state.output_ids =  get(handles.output_ids, 'String');
state.w2mhs_toolpath = get(handles.w2mhs_toolpath, 'String');
state.spm_tool_path = get(handles.spm_tool_path, 'String');
%state.input_method =  get(handles.input_method, 'value');
state.do_training = get(handles.do_training, 'value');
state.do_preproc = get(handles.do_preproc, 'value');
state.do_training = get(handles.do_training, 'value');
state.do_quantify = get(handles.do_quantify, 'value');
state.image_list = get(handles.image_list, 'String');
state.image_matrix = getappdata(handles.image_list, 'image_matrix');
state.def_path = getappdata(handles.add_button, 'def_path');
state.id_matrix = getappdata(handles.image_list, 'id_matrix');

save( file, 'state');

function opt_Callback(hObject, eventdata, handles)

if strcmp(get(handles.uipanel2, 'Visible'),'on');
    set(handles.uipanel2, 'Visible', 'off');

elseif strcmp(get(handles.uipanel2, 'Visible'),'off');
    set(handles.uipanel2, 'Visible', 'on');
end

function image_list_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function up_Callback(hObject, eventdata, handles)
index = get(handles.image_list, 'Value');
img_list = get(handles.image_list, 'String');
img_mat = getappdata(handles.image_list, 'image_matrix');
id_mat = getappdata(handles.image_list, 'id_matrix');
[row col] = size(img_list);
if (row > 0 && col > 0)
    if index ~= 1

        tmp = img_list{index-1};
        img_list{index-1} = img_list{index};
        img_list{index} = tmp;

        tmp = id_mat{index-1};
        id_mat{index-1} = id_mat{index};
        id_mat{index} = tmp;

        tmpA = img_mat{index-1,1};
        tmpB = img_mat{index-1,2};

        img_mat{index-1,1} = img_mat{index,1};
        img_mat{index-1,2} = img_mat{index,2};

        img_mat{index,1} = tmpA;
        img_mat{index,2} = tmpB;

        set(handles.image_list, 'Value', index-1);
        set(handles.image_list, 'String', img_list);
        setappdata(handles.image_list, 'image_matrix', img_mat);
        setappdata(handles.image_list, 'id_matrix', id_mat);
    end
end

function down_Callback(hObject, eventdata, handles)
index = get(handles.image_list, 'Value');
img_list = get(handles.image_list, 'String');
img_mat = getappdata(handles.image_list, 'image_matrix');
id_mat = getappdata(handles.image_list, 'id_matrix');
[row col] = size(img_list);
if (row > 0 && col > 0)
    if index ~= row

        tmp = img_list{index+1};
        img_list{index+1} = img_list{index};
        img_list{index} = tmp;

        tmp = id_mat{index+1};
        id_mat{index+1} = id_mat{index};
        id_mat{index} = tmp;

        tmpA = img_mat{index+1,1};
        tmpB = img_mat{index+1,2};

        img_mat{index+1,1} = img_mat{index,1};
        img_mat{index+1,2} = img_mat{index,2};

        img_mat{index,1} = tmpA;
        img_mat{index,2} = tmpB;

        set(handles.image_list, 'Value', index+1);
        set(handles.image_list, 'String', img_list);
        setappdata(handles.image_list, 'image_matrix', img_mat);
        setappdata(handles.image_list, 'id_matrix', id_mat);
    end
end

function batch_Callback(hObject, eventdata, handles)
display('test')

function i1_label_CreateFcn(hObject, eventdata, handles)

function i2_label_CreateFcn(hObject, eventdata, handles)

function add_button_CreateFcn(hObject, eventdata, handles)

function remove_CreateFcn(hObject, eventdata, handles)

function file_Callback(hObject, eventdata, handles)

function output_name_Callback(hObject, eventdata, handles)

function output_ids_Callback(hObject, eventdata, handles)

function output_path_Callback(hObject, eventdata, handles)

function spm_tool_path_Callback(hObject, eventdata, handles)

function w2mhs_toolpath_Callback(hObject, eventdata, handles)

function do_training_Callback(hObject, eventdata, handles)

function do_preproc_Callback(hObject, eventdata, handles)

function do_quantify_Callback(hObject, eventdata, handles)

function view_Callback(hObject, eventdata, handles)

function uipanel2_CreateFcn(hObject, eventdata, handles)

function image_list_Callback(hObject, eventdata, handles)

function output_name_KeyPressFcn(hObject, eventdata, handles)

function pushbutton13_CreateFcn(hObject, eventdata, handles)
display('It Works')


function pushbutton13_Callback(hObject, eventdata, handles)
display('It Works')



%END

