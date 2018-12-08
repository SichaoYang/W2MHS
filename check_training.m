
%% script for checking if all the post training files and/or data is available
% the script is triggered only when the do_train argument is chosen to be 'no'
function chk = check_training(training_path)
    if exist(fullfile(training_path, 'checkpoint'), 'file')  && ...
       exist(fullfile(training_path, 'Training_model.meta'), 'file')  && ...
       exist(fullfile(training_path, 'Training_model.index'), 'file') && ...
       exist(fullfile(training_path, 'Training_model.data-00000-of-00001'), 'file')
        disp('All training output present. Training is not required.');
        chk = true;
    else
        disp('Some training outputs are missing. Training is required.');
        chk = false;
        if ~exist(fullfile(training_path, 'features_training.mat'), 'file') || ...
           ~exist(fullfile(training_path, 'labels_training.mat'), 'file')
            error('Cannot find features_training.mat or labels_training.mat. Please download and place them under the training directory before training.')
        end
        disp('Rewrite the user''s option of doing training to ''yes''.');
    end
end