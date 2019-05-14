
%% script for checking for existence of all preprocessing files

% this function is triggered when do_preproc argument in WhyD_setup is given as 'no'

%%
function chk = check_preproc(obj)

num = size(names_stack,1);
chk = zeros(num,1);
for n = 1:num
    % checking each of the necerrasy files
    
    names = names_stack{n,1}; chk_n = 1;
    titles = ["BRAVO", "FLAIR", "c1rFLAIR", "c2rFLAIR", "c3rFLAIR", "vent_cut", "rFLAIR", "mrFLAIR", "Vent_strip", "GMCSF_strip", "WM_modstrip"];
    for i = 1:numel(titles)
        if ~exist(sprintf('%s/%s_%s.nii', names.directory_path, titles(i), names.folder_id), 'file');
            chk_n = 0;
            disp(1);
        end
    end
    if chk_n == 1
        % correcting names file as per the findings
        names.pve_flair_c1   = sprintf('c1rFLAIR_%s.nii',   names.folder_id);  
        names.pve_flair_c2   = sprintf('c2rFLAIR_%s.nii',   names.folder_id);
        names.pve_flair_c3   = sprintf('c3rFLAIR_%s.nii',   names.folder_id);
        names.flair_coreg    = sprintf('rFLAIR_%s.nii',     names.folder_id);
        names.flair_biascorr = sprintf('mrFLAIR_%s.nii',    names.folder_id);
        names.Vent           = sprintf('Vent_strip_%s.nii', names.folder_id);
        names.GMCSF          = sprintf('GMCSF_strip_%s.nii',names.folder_id);
        names.WM_mod         = sprintf('WM_modstrip_%s.nii',names.folder_id);
    end
    % save the names file
    save(sprintf('%s/names_%s.mat',names.directory_path,names.folder_id),'names');
    names_stack{n,1} = names; chk(n,1) = chk_n; clear names;
end

%% end
