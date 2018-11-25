%%  INSTALLATION SCRIPT
function installW2MHS()
    clc
    fprintf('______________________________________________________________________\n');
    fprintf('Wisconsin White Matter Hyperintensity Segmentation and Quantification:\n');
    
    %% Add W2MHS to FilePath
    w2mhstoolbox_path = fileparts(mfilename('fullpath'));
    addpath(genpath(w2mhstoolbox_path));
    fprintf('"%s" and its subdirectories successfully added to MATLAB path.\n' , w2mhstoolbox_path);

    %% Check Training Path
    v=ver;
    if ~exist('training', 'dir')
        error('The training folder is missing. Please download it from NITRC or SourceForge.');
    end
    
    %% Check Image Processing Toolbox
    v=ver;
    if ~any(strcmp({v.Name}, 'Image Processing Toolbox'))
        error('Please install Image Processing Toolbox first.');
    end

    %% Check Tools for NIfTI and ANALYZE image
    if ~exist('make_nii', 'file') || ...
       ~exist('save_nii', 'file') || ...
       ~exist('load_nii', 'file') || ...
       ~exist('view_nii', 'file')        
        error('Please download Tools for NIfTI and ANALYZE image and place it under the W2MHS toolbox folder.\n');
    end

    %% Install Python Dependencies
    fprintf('Check and install required Python packages with pip...\n');
    if system('python -m pip install --upgrade pip') ~= 0 || ...
       system(sprintf('python -m pip install -r %s/requirements.txt', w2mhstoolbox_path)) ~= 0
        error('Pip installation failed.');
    end

    %% Done
    fprintf('\n                     INSTALLATION COMPLETE \n');
    fprintf('To begin a GUI session, enter the command "W2MHS"\n');
    fprintf('______________________________________________________________________\n');
end
