%%  INSTALLATION SCRIPT
function installW2MHS()
    clc
    fprintf('______________________________________________________________________\n');
    fprintf('Wisconsin White Matter Hyperintensity Segmentation and Quantification:\n');
        
    %% Add W2MHS to FilePath
    w2mhstoolbox_path = fileparts(mfilename('fullpath'));
    training_path = fullfile(w2mhstoolbox_path, 'training');
    addpath(genpath(w2mhstoolbox_path));
    fprintf('"%s" and its subdirectories successfully added to MATLAB path.\n' , w2mhstoolbox_path);

    %%
    disp('Checking Matlab dependencies...');
    
    %% Check Training Path
    if ~exist(training_path, 'dir')
        error('The training folder is missing. Please download it from NITRC or SourceForge.');
    end
    
    %% Check Tools for NIfTI and ANALYZE image
    if ~exist('make_nii', 'file') || ...
       ~exist('save_nii', 'file') || ...
       ~exist('load_nii', 'file') || ...
       ~exist('view_nii', 'file')        
        error('Please download Tools for NIfTI and ANALYZE image and place it under the W2MHS toolbox folder.\n');
    end
    
    %% Check Image Processing Toolbox
    v=ver;
    if ~any(strcmp({v.Name}, 'Image Processing Toolbox'))
        error('Please install Image Processing Toolbox first.');
    end

    %% Pulling Dockerized Python Scripts    
    disp('Pulling dockerized python scripts...');
    if system('docker pull sichao/w2mhs:v2018.3') ~= 0
        error('Docker cannot pull sichao/w2mhs:v2018.3.');
    end

    %% Done
    fprintf('\n                     INSTALLATION COMPLETE \n');
    fprintf('To begin a GUI session, enter the command "W2MHS"\n');
    fprintf('______________________________________________________________________\n');
end
