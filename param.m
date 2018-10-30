function param(p, c, d)

%%      Hyperparameter Default Setup Script         %%
% The parameters in this script are additional options
% that affect various parts of the segmentation and
% quantification modules as well as some memory
% management.

%% Probability Map Cut
% This is the cutoff for deciding which voxels to include
% in the final quantification. All voxels with a probability
% below this threshold will be ignored when quantifying.
%
% Suggested default is .5

pmap_cut = .5;

%% Clean Threshold
% This is a distance measure. Any hyperintensities within
% this distance from the greay matter surface will be
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



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%                  DO NOT MODIFY BELOW THIS POINT                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(nargin ~= 3)
    
    if(clean_th < 0)
        clean_th = 0;
    end
    if( pmap_cut  < 0)
        pmap_cut = 0;
    elseif(pmap_cut > 1)
        pmap_cut = 1;
    end
    if(strcmp(delete_preproc,'Yes'))
        
    else
        delete_preproc = 'No';
    end
   

else
    clean_th = c;
    if(clean_th < 0)
        clean_th = 0;
    end
   pmap_cut = p;
    if(pmap_cut < 0)
        pmap_cut = 0;
    elseif(pmap_cut > 1)
        pmap_cut = 1;
    end
    
    delete_preproc = d;
    if(strcmpi(d,'yes'))
        delete_preproc = 'Yes';
    else
       delete_preproc = 'No';
    end
end
path = mfilename('fullpath');  path = strcat(path, '.m');
path = strrep(path, 'param.m', '');
file = strcat(path ,'Hyperparameters.mat');
save(file, 'delete_preproc', 'clean_th', 'pmap_cut');