function param(w2mhstoolbox_path, f, p, c, d)

%%      Hyperparameter Default Setup Script         %%
% The parameters in this script are additional options
% that affect various parts of the segmentation and
% quantification modules as well as some memory management.

%% Fold Size
% This is the number of voxels detected together.
% A larger fold size accelerates the detetion 
% at the expense of a higher memory consumption.
%
% Suggested default is 5000

fold_size = 5000;

%% Probability Map Cut
% This is the cutoff for deciding which voxels to include
% in the final quantification. All voxels with a probability
% below this threshold will be ignored when quantifying.
%
% Suggested default is .5

pmap_cut = .5;

%% Clean Threshold
% This is a distance measure. Any hyperintensities within
% this distance from the gray matter surface will be
% removed during postprocessing.
%
% Suggested default is 2.5

clean_th = 2.5;

%% Delete Preprocessing Files?
%  If you want to conserve disk space set this option to 'yes'
%  The preprocessing module will delete extraneous and
%  intermittent .nii files when they are no longer needed.
%  The only downside is that you will need to preprocess the
%  subjects again the next time you segment hyperintensities.
%
% Options: 'no' 'yes'  Suggested default: 'No'

delete_preproc = 'No';

if nargin > 1 && ~isnan(f), fold_size = f; end
if nargin > 2 && ~isnan(c), clean_th = c; end
if nargin > 3 && ~isnan(p), pmap_cut = p; end
if nargin > 4, delete_preproc = d; end
    
fold_size = max(fold_size, 1);
clean_th = max(clean_th, 0);
pmap_cut = max(min(pmap_cut, 1), 0);
if strcmpi(delete_preproc,'yes')
    delete_preproc = 'Yes';
else
    delete_preproc = 'No';
end
save(fullfile(w2mhstoolbox_path, 'Hyperparameters.mat'), 'fold_size', 'clean_th', 'pmap_cut', 'delete_preproc');