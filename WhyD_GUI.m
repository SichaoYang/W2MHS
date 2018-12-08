function varargout = WhyD_GUI(varargin)
    %% W2MHS_GUI M-file for WhyD_GUI.fig
    %
    %   W2MHS_GUI, is the GUI for the White Matter Hyperintensity
    %   Segmentation and Quantification application created by Vamsi Ithapu.
    %
    %   Author: Chris Lindner.
    %
    % Last Modified by Sichao Yang 25-Nov-2018

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
    % Choose default command line output for W2MHS
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    clc
    fprintf('______________________________________________________________________\n');
    disp('   White Matter Hyperintensity Segmentation and Quantification');
    disp('University of Wisconsin - Wisconsin Alzheimers Disease Research Center');
    disp('Initializing W2MHS........');

    axes(handles.pic);
    imshow('brain.jpg');
    axes(handles.axes2);
    imshow('uw.png');

    set(hObject, 'Name', 'W2MHS');
    
    new_Callback(hObject, eventdata, handles)

% --- Outputs from this function are returned to the command line.
function varargout = WhyD_GUI_OutputFcn(~, ~, handles)
    varargout{1} = handles.output;

% --- Executes on button press in output_path_button.
function output_path_button_Callback(hObject, ~, handles)
    %file_path = uigetdir(getappdata(hObject, 'path'));
    file_path = uigetdir_workaround(getappdata(hObject, 'path'));
    if ~isequal(file_path, 0)
        set(handles.output_path, 'string', file_path);
        setappdata(hObject, 'path', file_path);
    end
    
% --- Executes on button press in add_button.
function add_button_Callback(hObject, eventdata, handles)
    choice = questdlg('What would you like to add?', 'Add images...', ...
        'Single Subject', 'Directory', 'Single Subject');

    if(strcmp(choice, 'Single Subject'))
        [input_image_t1,path1] = uigetfile({'*.nii'},'Select T1 Image...',getappdata(hObject, 'def_path'));
        if ~isequal(path1, 0)
            file1 = strcat(path1,input_image_t1);
            setappdata(hObject, 'def_path', path1);
            setappdata(hObject, 'path1', path1);
            [input_image_t2,path2] = uigetfile({'*.nii'},'Select T2 Image...',getappdata(hObject, 'def_path'));
            if ~isequal(path2, 0)
                setappdata(hObject, 'path2', path2);
                file2 = strcat(path2, input_image_t2);
            
                fNam = lower(input_image_t1);
                ind = regexp(fNam, '[0-9].*');

                defID = {''};
                if ind
                    defID{1} = strrep(strrep(strrep(strrep(strrep(fNam(ind:end),...
                        'bravo',''),'flair',''),'__','_'),'.nii',''),' ','');
                end

                id = inputdlg('Enter a subject ID:','Specify Identifier...',[1 25],defID);

                if numel(id) == 1
                    tmp = get(handles.image_list, 'String');
                    [row, ~] = size(tmp);

                    spaces = ',';
                    if numel(id{1}) < 15
                        for i = 1 : 15 - numel(id{1})
                            spaces = cat(2,spaces, ' ');
                        end
                    end

                    string(1:79) = 'ID:                    T1:                         T2:                         ';
                    endInd = min(4+numel(id{1})-1, 22);
                    string(4:endInd) = id{1}(1:endInd-3);

                    endInd = min(27+numel(input_image_t1)-1, 50);
                    string(27:endInd) = input_image_t1(1:endInd-26);

                    endInd = min(56+numel(input_image_t2)-1, 79);
                    string(56:endInd) = input_image_t2(1:endInd-55);


                    tmp{row+1} = string;
                    set(handles.image_list, 'String', tmp);

                    image_matrix = getappdata(handles.image_list, 'image_matrix');
                    id_matrix = getappdata(handles.image_list, 'id_matrix');

                    [row, ~] = size(image_matrix);
                    image_matrix{row+1,1} = file1;
                    image_matrix{row+1,2} = file2;
                    id_matrix{row+1,1} = id{1};

                    setappdata(handles.image_list, 'image_matrix', image_matrix);
                    setappdata(handles.image_list, 'id_matrix', id_matrix);
                    set(handles.image_list, 'Value', row+1);
                end
            end
        end
    elseif(strcmp(choice, 'Directory'))
        %path = uigetdir(getappdata(hObject, 'def_path'),'Select Batch Directory');
        path = uigetdir_workaround(getappdata(hObject, 'def_path'),'Select Batch Directory');
        if ~isequal(path, 0)
            WhyD_batch(hObject, eventdata, handles, path);
        end

    end
% --- Executes on button press in add_button. a single one of those
function remove_Callback(~, ~, handles)
    index = get(handles.image_list, 'Value');
    tmp = get(handles.image_list, 'String');
    image_matrix = getappdata(handles.image_list, 'image_matrix');
    id_matrix = getappdata(handles.image_list, 'id_matrix');
    [row, col] = size(tmp);
    if (row > 0 && col > 0)
        tmp{index,1} = 0;
        tmp = tmp(cellfun('isclass', tmp(:,1), 'char'),:);

        image_matrix{index,1} = 0; image_matrix{index,2} = 0;
        image_matrix = image_matrix(cellfun('isclass', image_matrix(:,1), 'char'),:);

        id_matrix{index,1} = 0; id_matrix{index,2} = 0;
        id_matrix = id_matrix(cellfun('isclass', id_matrix(:,1), 'char'),:);

        set(handles.image_list, 'Value', 1);
        set(handles.image_list, 'String', tmp);

        setappdata(handles.image_list, 'image_matrix', image_matrix);
        setappdata(handles.image_list, 'id_matrix', id_matrix);
    end
    
function [b, a] = swap(a, b)
    
function up_Callback(~, ~, handles)
    index = get(handles.image_list, 'Value');
    img_list = get(handles.image_list, 'String');
    img_mat = getappdata(handles.image_list, 'image_matrix');
    id_mat = getappdata(handles.image_list, 'id_matrix');
    [row, col] = size(img_list);
    if (row > 0 && col > 0)
        if index > 1
            [img_list{index-1}, img_list{index}] = swap(img_list{index-1}, img_list{index});
            [id_mat{index-1}, id_mat{index}] = swap(id_mat{index-1}, id_mat{index});
            [img_mat{index-1,1}, img_mat{index,1}] = swap(img_mat{index-1,1}, img_mat{index,1});
            [img_mat{index-1,2}, img_mat{index,2}] = swap(img_mat{index-1,2}, img_mat{index,2});
            
            set(handles.image_list, 'Value', index-1);
            set(handles.image_list, 'String', img_list);
            setappdata(handles.image_list, 'image_matrix', img_mat);
            setappdata(handles.image_list, 'id_matrix', id_mat);
        end
    end

function down_Callback(~, ~, handles)
    index = get(handles.image_list, 'Value');
    img_list = get(handles.image_list, 'String');
    img_mat = getappdata(handles.image_list, 'image_matrix');
    id_mat = getappdata(handles.image_list, 'id_matrix');
    [row, col] = size(img_list);
    if (row > 0 && col > 0)
        if index < row
            [img_list{index+1}, img_list{index}] = swap(img_list{index+1}, img_list{index});
            [id_mat{index+1}, id_mat{index}] = swap(id_mat{index+1}, id_mat{index});
            [img_mat{index+1,1}, img_mat{index,1}] = swap(img_mat{index+1,1}, img_mat{index,1});
            [img_mat{index+1,2}, img_mat{index,2}] = swap(img_mat{index+1,2}, img_mat{index,2});
            
            set(handles.image_list, 'Value', index+1);
            set(handles.image_list, 'String', img_list);
            setappdata(handles.image_list, 'image_matrix', img_mat);
            setappdata(handles.image_list, 'id_matrix', id_mat);
        end
    end

% --- Executes on button press in run_button.
function run_button_Callback(~, ~, handles)
    clc
    %% Format Arguments
    output_name = {get(handles.output_name, 'String')};
    output_path = {get(handles.output_path, 'String')};
    input_images = getappdata(handles.image_list, 'image_matrix') ; 
    output_ids = getappdata(handles.image_list, 'id_matrix');
    w2mhstoolbox_path = get(handles.w2mhs_toolpath, 'String');
    spm_tool_path = get(handles.spm_tool_path, 'String');
    
    tmp = get(handles.do_training, 'String');
    do_train = tmp{get(handles.do_training, 'value')};
    tmp = get(handles.do_preproc,'String');
    do_preproc = tmp{get(handles.do_preproc, 'value')};
    tmp = get(handles.do_quantify, 'String');
    do_quantify = tmp{get(handles.do_quantify, 'value')};
    tmp = get(handles.do_visualization, 'String');
    do_visualize = tmp{get(handles.do_visualization, 'value')};
    
    pmap_cut = str2double(get(handles.edit6, 'String'));
    clean_th = str2double(get(handles.edit7, 'String'));
    tmp = get(handles.popupmenu5, 'String');
    delete_preproc = tmp{get(handles.popupmenu5, 'value')};
    
    param(w2mhstoolbox_path, clean_th, pmap_cut, delete_preproc);

    %% Run WhyD
    WhyD_setup(output_name, output_path, input_images, output_ids, ...
        w2mhstoolbox_path, spm_tool_path, do_train, do_preproc, do_quantify, do_visualize, 2);

% --- Executes on button press in w2mhs_tool.
function w2mhs_tool_Callback(hObject, ~, handles)
    file_path = uigetdir_workaround(getappdata(hObject, 'path'));
    if ~isequal(file_path, 0)
        set(handles.w2mhs_toolpath,'string', file_path);
        setappdata(hObject, 'path', file_path);
    end

% --- Executes on button press in spm_tool.
function spm_tool_Callback(hObject, eventdata, handles)
    file_path = uigetdir_workaround(getappdata(hObject, 'path'));
    if ~isequal(file_path, 0)
        set(handles.spm_tool_path,'String', file_path);
        setappdata(hObject, 'path', file_path);
    end
    
function load_state(handles, file)
    load(file, 'state');
    
    set(handles.output_name, 'String', state.output_name);
    set(handles.output_path, 'String', state.output_path);
    set(handles.w2mhs_toolpath, 'String', state.w2mhs_toolpath);
    if isempty(state.w2mhs_toolpath), set(handles.w2mhs_toolpath, 'String', path); end
    set(handles.spm_tool_path, 'String', state.spm_tool_path);
    set(handles.do_training, 'value', state.do_training);
    set(handles.do_preproc, 'value', state.do_preproc);
    set(handles.do_quantify, 'value', state.do_quantify);
    set(handles.do_visualization, 'value', state.do_visualization);
    set(handles.image_list, 'String', state.image_list);
    setappdata(handles.image_list, 'image_matrix', state.image_matrix);
    setappdata(handles.add_button, 'def_path', state.def_path)
    setappdata(handles.image_list, 'id_matrix', state.id_matrix);

function path = def_path()
    if isdeployed
        [~, path] = system('echo $W2MHS_HOME');
        path = path(1:end-1);
        if isempty(path), path = pwd; end
    else
        path = fileparts(mfilename('fullpath'));
    end
    
function new_Callback(~, ~, handles)
    path = def_path();
    file = fullfile(path, 'default.mat');
    if exist(file, 'file')
        try
            load_state(handles, file);
        catch e
            disp(e)
            errordlg('Issue loading default configuration', 'Error');
        end
    else
        set(handles.output_name, 'String', '');
        set(handles.output_path, 'String', '');
        set(handles.w2mhs_toolpath, 'String', path);
        set(handles.spm_tool_path, 'String', '');
        set(handles.do_training, 'value', 1);
        set(handles.do_preproc, 'value', 1);
        set(handles.do_quantify, 'value', 1);
        set(handles.do_visualization, 'value', 1);
        set(handles.image_list, 'String', cell(0,1));
        setappdata(handles.image_list, 'image_matrix', cell(0,2));
        setappdata(handles.image_list, 'id_matrix', cell(0,2));
        setappdata(handles.add_button, 'def_path', path);
    end

function open_Callback(~, ~, handles)
    [FileName,PathName] = uigetfile('.mat','Open file...');
    if ~isequal(FileName, 0) && ~isequal(PathName, 0)
        file = strcat(PathName,FileName);
        if (exist(file, 'file')), load_state(handles, file); end
    end

function save_state(handles, file)
    state.output_name = get(handles.output_name, 'String');
    state.output_path =  get(handles.output_path, 'String');
    state.w2mhs_toolpath = get(handles.w2mhs_toolpath, 'String');
    state.spm_tool_path = get(handles.spm_tool_path, 'String');
    state.do_preproc = get(handles.do_preproc, 'value');
    state.do_training = get(handles.do_training, 'value');
    state.do_quantify = get(handles.do_quantify, 'value');
    state.do_visualization = get(handles.do_visualization, 'value');
    state.image_list = get(handles.image_list, 'String');
    state.image_matrix = getappdata(handles.image_list, 'image_matrix');
    state.def_path = getappdata(handles.add_button, 'def_path');
    state.id_matrix = getappdata(handles.image_list, 'id_matrix');

    save(file, 'state');
    
function save_Callback(~, ~, handles)

    [FileName,PathName] = uiputfile('W2MHS_save.mat','Save as...');
    if ~isequal(FileName, 0) && ~isequal(PathName, 0)
        save_state(handles, strcat(PathName, FileName));
    end
    
function def_Callback(~, ~, handles)
    path = fileparts(mfilename('fullpath'));
    file = fullfile(path, 'default.mat');
    save_state(handles, file);

function close_Callback(~, ~, handles)
    clc
    disp('Bye for now...');
    delete(handles.figure1);
    
function figure1_CloseRequestFcn(hObject, ~, ~)
    delete(hObject);

function opt_Callback(~, ~, handles)
    if strcmp(get(handles.uipanel2, 'Visible'),'on')
        set(handles.uipanel2, 'Visible', 'off');
    elseif strcmp(get(handles.uipanel2, 'Visible'),'off')
        set(handles.uipanel2, 'Visible', 'on');
    end

%% --- Executes during object creation, after setting all properties.
function createFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function w2mhs_toolpath_CreateFcn(hObject, eventdata, handles)
    createFcn(hObject, eventdata, handles);
    set(hObject,'string', def_path());
