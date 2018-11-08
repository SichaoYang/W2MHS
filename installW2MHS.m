%%  INSTALLATION SCRIPT
function installW2MHS()
    if nargin < 1, install_py=false; end
    clc
    fprintf('______________________________________________________________________\n');
    fprintf('Wisconsin White Matter Hyperintensity Segmentation and Quantification:\n');
    
    %% Add W2MHS to FilePath
    spmtoolbox_path = fileparts(mfilename('fullpath'));
    addpath(genpath(spmtoolbox_path));
    fprintf('"%s" and its subdirectories successfully added to MATLAB path.\n' , spmtoolbox_path);

    %% Check Training Path
    v=ver;
    if ~exist('training', 'dir')
        error("The training folder is missing. Please download it from NITRC or SourceForge.")
    end
    
    %% Check Image Processing Toolbox
    v=ver;
    if ~any(strcmp({v.Name}, 'Image Processing Toolbox'))
        error("Please install Image Processing Toolbox first.")
    end

    %% Check Tools for NIfTI and ANALYZE image
    if ~exist('make_nii', 'file') || ...
       ~exist('save_nii', 'file') || ...
       ~exist('load_nii', 'file') || ...
       ~exist('view_nii', 'file')        
        error("Please download Tools for NIfTI and ANALYZE image and place it under the W2MHS toolbox folder.\n")
    end

    %% Install Python Dependencies
    fprintf('Check and install required Python packages with pip...\n');
    if system(sprintf("pip install -r %s/requirements.txt", spmtoolbox_path)) ~= 0
        error("Pip installation failed. See information above.")
    end

    %% Done
    fprintf('\n                     INSTALLATION COMPLETE \n');
    fprintf('To begin a GUI session, enter the command "W2MHS"\n');
    fprintf('______________________________________________________________________\n');
end
