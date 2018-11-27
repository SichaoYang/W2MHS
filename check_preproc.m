
%% script for checking for existence of all preprocessing files

% this function is triggered when do_preproc argument in WhyD_setup is given as 'no'

%%
function [chk, names_stack] = check_preproc(names_stack)

num = size(names_stack,1);
chk = zeros(num,1);
for n = 1:num
    % checking each of the necerrasy files
    
    names = names_stack{n,1}; var = 0;
    var = var + exist(sprintf('%s/BRAVO_%s.nii',      names.directory_path,names.folder_id),'file');
    var = var + exist(sprintf('%s/FLAIR_%s.nii',      names.directory_path,names.folder_id),'file');
    var = var + exist(sprintf('%s/c1rFLAIR_%s.nii',   names.directory_path,names.folder_id),'file');
    var = var + exist(sprintf('%s/c2rFLAIR_%s.nii',   names.directory_path,names.folder_id),'file');
    var = var + exist(sprintf('%s/c3rFLAIR_%s.nii',   names.directory_path,names.folder_id),'file');
    var = var + exist(sprintf('%s/vent_cut_%s.nii',   names.directory_path,names.folder_id),'file');
    var = var + exist(sprintf('%s/rFLAIR_%s.nii',     names.directory_path,names.folder_id),'file');
    var = var + exist(sprintf('%s/mrFLAIR_%s.nii',    names.directory_path,names.folder_id),'file');
    var = var + exist(sprintf('%s/Vent_strip_%s.nii', names.directory_path,names.folder_id),'file');
    var = var + exist(sprintf('%s/GMCSF_strip_%s.nii',names.directory_path,names.folder_id),'file');
    var = var + exist(sprintf('%s/WM_modstrip_%s.nii',names.directory_path,names.folder_id),'file');
    
    %% These files were eliminated from preprocessing as they are not used
    %var = var + exist(sprintf('%s\c0rFLAIR_%s.nii',names.directory_path,names.folder_id),'file');
    %var = var + exist(sprintf('%s\GM_strip_%s.nii',names.directory_path,names.folder_id),'file');
    %var = var + exist(sprintf('%s\CSF_strip_%s.nii',names.directory_path,names.folder_id),'file');
    %var = var + exist(sprintf('%s\PVE_cut_%s.nii',names.directory_path,names.folder_id),'file');

    
    if var == 22 chk_n = 1; else chk_n = 0; end
    if chk_n == 1
        % correcting names file as per the findings
        %% Correct c0
        names.pve_flair_c1   = sprintf('c1rFLAIR_%s.nii',   names.folder_id);  
        names.pve_flair_c2   = sprintf('c2rFLAIR_%s.nii',   names.folder_id);
        names.pve_flair_c3   = sprintf('c3rFLAIR_%s.nii',   names.folder_id);
        names.flair_coreg    = sprintf('rFLAIR_%s.nii',     names.folder_id);
        names.flair_biascorr = sprintf('mrFLAIR_%s.nii',    names.folder_id);
        names.Vent           = sprintf('Vent_strip_%s.nii', names.folder_id);
        names.GMCSF          = sprintf('GMCSF_strip_%s.nii',names.folder_id);
        names.WM_mod         = sprintf('WM_modstrip_%s.nii',names.folder_id);
        
        %names.pve_flair_c0 = sprintf('c0rFLAIR_%s.nii',names.folder_id);
        %names.WM = sprintf('WM_strip_%s.nii',names.folder_id);
        %names.GM = sprintf('GM_strip_%s.nii',names.folder_id);
        %names.CSF = sprintf('CSF_strip_%s.nii',names.folder_id);
        %names.Vent = sprintf('Vent_strip_%s.nii',names.folder_id);
        % names.seg_pmap = sprintf('PVE_cut_%s.nii',names.folder_id);
    end
    % saving the names file
    save(sprintf('%s/names_%s.mat',names.directory_path,names.folder_id),'names');
    names_stack{n,1} = names; chk(n,1) = chk_n; clear names;
end

%% end