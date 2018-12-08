                    clear all; clc
%%    Welcome to the Batch Processing module for W2MHS!
% 
%  Use this script when you have a lot of subjects to process. There are
%  other ways to write a batch script for the W2MHS toolbox; however we
%  wanted to include an easy to use, premade batch script. 
%
%  To use this script first make sure your files follow the naming
%  convention below and are in the same directory. Then fill out the
%  parameters below and run the script...
% 
%  PLEASE NOTE: The only caveat to this script is that it requires your T1
%  (BRAVO) and T2 (FLAIR) images to follow a fairly general naming
%  convention. Also, for simplicty, all of your subjects must be in the
%  same directory.
%
%%   NAMING CONVENTIONS: (none of which are case sensitive)
%  
%
%  [Batch Name][Unique Identifier][BRAVO\\FLAIR].nii
%  [Batch Name]_[Unique Identifier]_[BRAVO\\FLAIR].nii
%
%  [Batch Name]  =  This is a name that summarizes the whole batch. It could
%  be a study name or group name that all of the images come from. the
%  batch name should be the same on all files. NOTE: This script takes the first
%  Batch Name it is given and assumes that this is the name for every
%  subject in the batch. (This is not always the first image.)
%
%
%  [Unique Identifier]  =  This must begin with an integer (i.e. subject number)
%  that follows the batch name. After the integer you may have additional
%  identifiers such as a string. The Unique Identifier MUST BE THE SAME for
%  the correspoding T1 and T2 images. 
%
%
%  [BRAVO\FLAIR]  =  The string 'BRAVO' or 'FLAIR' must be present
%  somewhere in the filename AFTER the the integer that is a unique
%  identifier. 
%
%%  SOME EXAMPLES
%  
%  "mrt87flair.nii"             "mrt87bravo.nii"
%
%  "mrt 87 FLAIR.nii"           "mrt 87 BrAvO.nii"
%
%  "mrt_87_v2_Flair_ver1.nii"   "mrt_87_v2_Bravo_ver1.nii"
%
%  "mrt87_v2_ver1_FLAIR.nii"    "mrt87_v2_ver1_BRAVO.nii"
%
% 
% %}
%%                       PARAMETERS
%   Modify the following parameters:

%%  batch_path: 
%   --This is where all of your T1 and T2 images should be stored.  This
%   script will automatically grab all of the image pairs it finds in the
%   directory. Keep the '\' at the end!
    batch_path = '\home\user\Documents\Study_data\batch_directory\';
    
%%  output_path: 
%   --This is where the segmentation outputs will be written. Each subject
%   will have its own directory created to separate outputs.  Keep the '\'
%   at the end!
    output_path = {'\home\user\Documents\Study_data\Outputs\'};
    
%%  w2mhstoolbox_path: 
%   --This is where the W2MHS codes are stored on your computer.

    w2mhstoolbox_path = '\home\shared\matlab\toolbox\W2MHS';

%%  batch_path: 
%   --This is where SPM 12b is located
    spmtoolbox_path = '\home\shared\matlab\toolbox\spm12b';

%% Options::

%% Train a new segmentation model?
do_train = 'no'; 

%% Do preprocessing on all subjects?
do_preproc = 'no'; 

%% Quantify your results?
do_quantify = 'yes';




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%                  DO NOT MODIFY BELOW THIS POINT                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


addpath(spmtoolbox_path); batch = dir(batch_path);
s = size(batch); images = {};ids = {}; name = {'0'};

for i = 3 : s(1)
    fNam = lower(batch(i).name);
    br = regexp(fNam, 'bravo');
    ind = regexp(fNam, '[0-9].*');
    if ind, found = 1;
    else,   found = 0; ind = 0;
    end
    
    id = strrep(strrep(strrep(strrep(strrep(fNam(max(ind,1):end),...
        'bravo',''),'flair',''),'__','_'),'.nii',''),' ','');
    if name{1,1} == '0'
        name = {strrep(strrep(fNam(1:ind-1),'_',''),' ','')};
    end
    
    if (numel(br) == 1)
        for j = 4 : s(1)
            search = strrep(fNam,'bravo', 'flair');
            if(strcmp(batch(j).name,search))
                found = j;
                [row, ~] = size(images);
                image1 = strcat(output_path,batch(i).name);
                image2 = strcat(output_path,batch(j).name);
                images{row+1,1} = image1{1,1};
                ids{row+1,1} = id;
                images{row+1,2} = image2{1,1};
            end
        end
    end

    if found == 0 && numel(br) == 1
        fprintf('Could not find a match for: %s\n', batch(i).name);
    end
end

clear batch s i j fNam br ind found id search row

s = size(images);

choice = questdlg(strcat('Found "', int2str(s(1,1)), '" subjects with matching BRAVO and FLAIR images in directory:  "', ...
    batch_path, '"  Would you like to continue with W2MHS?'), ...
    'Continue?', ...
    'Yes', 'No', 'Yes');

if(strcmp(choice, 'Yes'))
    
    % Run W2MHS
    WhyD_setup(name, output_path, images, ids, w2mhstoolbox_path, spmtoolbox_path,'rf_regress', do_train, do_preproc, do_quantify);
end
