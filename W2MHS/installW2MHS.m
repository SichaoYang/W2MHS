%%  INSTALLATION SCRIPT
function installW2MHS()
    clc
    disp('______________________________________________________________________');
    disp('Wisconsin White Matter Hyperintensity Segmentation and Quantification');
    
     %% Add W2MHS to FilePath
    addpath(genpath(pwd));
    savepath()
    fprintf('\n"%s" and its \n subdirectories successfully added to MATLAB path.\n', pwd);
     
    fprintf('\nChecking prerequisites:\n');
    
    %% Check Image Processing Toolbox
    v=ver;
    if any(strcmp({v.Name}, 'Image Processing Toolbox'))
        disp('    Image Processing Toolbox presents.')
    else
        error('    Please install Image Processing Toolbox.');
    end
    
    %% Check Tools for NIfTI and ANALYZE image
    if exist('NIFTI_codes', 'dir')
        disp('    Tools for NIfTI and ANALYZE image presents.')
    else
        error('    Please download Tools for NIfTI and ANALYZE image and unzip it under the toolbox folder.\n');
    end
    
    %% Check Training
    if exist(fullfile(pwd, 'training', 'model.mat'), 'file')
        disp('    Pre-trained model presents.')
    else
        error('    Pre-trained model not found. Please redownload model.mat or train your own model.');
    end
    
    %% Done
    fprintf('\n\n                     INSTALLATION COMPLETE\n');
    fprintf('        To begin a GUI session, enter the command "W2MHS"\n');
    fprintf('______________________________________________________________________\n');
end
