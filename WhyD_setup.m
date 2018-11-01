
%% Setup script for segmenting and quantifying white matter hyperintensities on T2-FLAIR MRI images

% mandatory input arguments ....
% output_name, output_ids : identifiers for outputs folder
% output_name is a character string, output_ids is a alphanumeric string
% output_path : path where the outputs will be stored
% input_images : path of the T1 and T2 images (raw), in that order
% w2mhstoolbox_path : path where the codes, features and training data of W2MHS are located

% optional input arguments ....
% do_train : training to de done or not
% options include 'yes', 'no' (case insensitive) ; default is 'no'
% do_preproc : preprocessing to be done or not
% options include 'yes', 'no' (case insensitive) ; default is 'yes'
% do_quantify : quantification of detections to be done ot not
% options include 'yes', 'no' (case insensitive) ; default is 'yes'

% multiple subjects can be processed by changing the input arguments
% folder(s) are created inside output_path depending on the number of subjects being processed
% their name are constructed using the identifiers, output_name and output_ids

% EXAMPLE 1:
% w2mhstoolbox_path = '\home\Documents\W2MHS\';
% spmtoolbox_path = '\home\spm12b';
% output_name = {'mystudy'}; output_ids = {'a1'};
% output_path = {'\home\Documents\W2MHSoutputs\'};
% input_images = {'\home\Documents\images\T1.nii','\home\Documents\images\T2.nii'};
% input_meth = {'rf_class'}
% do_train = {'yes'}; do_preproc = {'yes'}; do_quantify = {'no'};
% WhyD_setup(output_name, output_path, input_images, output_ids, w2mhstoolbox_path, spmtoolbox_path);

% EXAMPLE 2:
% w2mhstoolbox_path = '\home\Documents\W2MHS\';
% spmtoolbox_path = '\home\spm12b';
% output_name = {'mystudy'}; output_ids = {'a1';'a2';'b1'};
% output_path = {'\home\Documents\W2MHSoutputs\'};
% input_images = {'\home\Documents\images\S1\T1.nii','\home\Documents\images\S1\T2.nii';...
% '\home\Documents\images\S2\T1.nii','\home\Documents\images\S2\T2.nii';'\home\Documents\images\S3\T1.nii','\home\Documents\images\S3\T2.nii'};
% WhyD_setup(output_name, output_path, input_images, output_ids, w2mhstoolbox_path, spmtoolbox_path);

%%
function WhyD_setup(output_name, output_path, input_images, output_ids, w2mhstoolbox_path, spmtoolbox_path,do_train, do_preproc, do_quantify, GUI, do_visualize)
training_path = fullfile(w2mhstoolbox_path, 'training');

%% checking for correct number of inputs
if nargin < 6
    error('Input error: Not enough input agruments for WhyD_setup! \n');
end
if ~exist('do_train','var'),        do_train = 'no';      end
if ~exist('do_preproc','var'),      do_preproc = 'yes';   end
if ~exist('do_quantify','var'),     do_quantify = 'yes';  end
if ~exist('do_visualize','var'),    do_visualize = 'yes'; end
if ~exist('GUI','var') || GUI ~= 2, param();              end

%% rearranging inputs
input_name = output_name; input_path = output_path; input_ids = output_ids;
clear output_name output_path output_ids;

%% finding the number of subjects being processed
if sum(size(input_name)-[1,1])~= 0 || sum(size(input_path)-[1,1])~= 0 
    error('Input error: input_name and input_path should have only single string in each! \n');
end
if size(input_images,1)~=size(input_ids,1)
    error('Input error: Size mismatch between number of T1-T2 images pairs and input_ids');
end
num = size(input_images,1);
if ~exist(fullfile(w2mhstoolbox_path, 'Hyperparameters.mat'), 'file')
    param;
end
load(fullfile(w2mhstoolbox_path, 'Hyperparameters.mat'), 'clean_th', 'pmap_cut', 'delete_preproc');
fprintf('USING HYPERPARAMETERS: \n  P-Map Cut: %g \n  Clean Thresh: %g \n  Conserve Memory: %s \n\n', ...
pmap_cut, clean_th, delete_preproc);
%% starting the expermients
fprintf('START \n');

%% initializing necessary files and directories
names_stack = cell(num,1);
fprintf('Creating necessary folders and variables for segmentation \n');
for n = 1:1:num
    names.folder_name    = input_name{1,1};
    names.folder_id      = input_ids{n,1};
    names.directory_path = sprintf('%s/%s_%s', input_path{1,1}, names.folder_name, names.folder_id);
    names.source_bravo   = sprintf('BRAVO_%s.nii', names.folder_id);
    names.source_flair   = sprintf('FLAIR_%s.nii', names.folder_id);
    names.w2mhstoolbox_path = w2mhstoolbox_path;
    names_stack{n,1} = names;
    mkdir(names.directory_path);
    copyfile(input_images{n,1}, sprintf('%s/BRAVO_%s.nii', names.directory_path, names.folder_id));
    copyfile(input_images{n,2}, sprintf('%s/FLAIR_%s.nii', names.directory_path, names.folder_id));
    save(sprintf('%s/names_%s.mat', names.directory_path, names.folder_id), 'names');
    clear names;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                 ONE MODULE AT A TIME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% preprocessing data
% if do_preproc is 'no', checks if preprocessing is required
check_preproc_vals = zeros(num, 1); 
fprintf('User chose to preprocess the data : %s \n',do_preproc);
if strcmpi(do_preproc, 'no')
    [check_preproc_vals, names_stack] = check_preproc(names_stack);
    if sum(check_preproc_vals) ~= num
        fprintf('There are preprocessed outputs missing for some/all subjects! \n');
        fprintf('Rewriting the user''s option of doing preprocessing to ''yes'' for those missing subjects! \n' );
        do_preproc = 'yes';
    else
        fprintf('Have all the necessary files. Skipping preprocessing as per user''s choice \n');
    end
end
% if required, preprocess the subjects by calling WhyD_preproc
if strcmpi(do_preproc, 'yes')
    for n = 1:num
        if check_preproc_vals(n) == 0
            names_stack{n,1} = WhyD_preproc(names_stack{n,1}, spmtoolbox_path);
        end
    end
    fprintf('Done preprocessing \n');
end

%% training the segmentation model
fprintf('User chose to train the segmentation method : %s \n',do_train);
% if do_train is 'no', checks if training is required
if strcmpi(do_train,'yes') || ~check_training(training_path)
    fprintf('Training (Neural Network based classification) \n');
    % if performance_metrics i.e. ROC or confusion matrix needs to be printed, set False to True.
    system(sprintf('python %s/W2MHS_training.py False', w2mhstoolbox_path));
    fprintf('Done training \n');
end

%% segmenting the hyperintensities on input images
fprintf('Segmenting hyperintensities on input images \n');
for n = 1:num
    names_stack{n,1} = WhyD_detect(names_stack{n,1}, training_path);
    names_stack{n,1} = WhyD_postproc(names_stack{n,1});
end
fprintf('Done segmenting (and postprocessing) \n');

%% quantifying the detections
fprintf('User chose to quantify the hyperintensity accumulation : %s \n',do_quantify);
if strcmpi(do_quantify, 'yes')
    fprintf('Quantifying hyperintensity accumulation \n');
    for n = 1:num
        names_stack{n,1} = WhyD_quant(names_stack{n,1});
    end
    fprintf('Done quantifying \n');
end

%% visualizing the output
colorbar = jet(256);
if strcmpi(do_visualize, 'yes')
    fprintf('Creating heatmaps \n');
    for n = 1:num
        names_stack{n,1} = WhyD_visual(names_stack{n,1}, colorbar, 0);
    end
    if num == 1
        names = names_stack{1,1};
        view_nii(load_nii(fullfile(names.directory_path, names.heatmap)));
    end
    fprintf('Done visualization \n');
end

%% done will all experiments
fprintf('DONE \n');
delete(fullfile(w2mhstoolbox_path, 'Hyperparameters.mat'))

%% end