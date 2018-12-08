
%% script for preprocessing the raw T1 and T2 input files

%%
function names = WhyD_preproc(names, spmtoolbox_path)

fprintf('\nDoing preprocessing on subject : %s_%s \n',names.folder_name,names.folder_id);
if ~isdeployed
    addpath(spmtoolbox_path);
    spm('defaults','FMRI');
end

if ~exist(fullfile(spmtoolbox_path, 'tpm', 'TPM.nii'), 'file')
    error(  'Could not find TPM.nii! \n\n Make sure the toolbox path is correct!');
end

%% generating batch file for coregistration
fid = fopen(sprintf('%s/coreg%s_job.m',names.directory_path,names.folder_id),'w+');
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {''%s/%s,1''};\n',names.directory_path,names.source_bravo);
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.source = {''%s/%s,1''};\n',names.directory_path,names.source_flair);
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''''};\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = ''nmi'';\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = ''r'';\n');
fclose(fid);

%% coregistering flair image to bravo
fprintf('Coregistration of T2-FLAIR to T1\n');

job = sprintf('%s/coreg%s_job.m',names.directory_path,names.folder_id);
if isdeployed
    if system(sprintf('%s batch %s', fullfile(spmtoolbox_path, 'spm12'), job)) ~= 0
        error('Could not intialize SPM12 preprocessing! \n\n  Make sure the toolbox path is correct!');
    end
else
    try
        spm_jobman('run', {job});
    catch
        error('Could not intialize SPM12 preprocessing! \n\n  Make sure you have SPM12 installed and the path is correct...');
    end
end
clear job;
names.flair_coreg = sprintf('rFLAIR_%s.nii',names.folder_id);


%% generating batch file for tissue labels segmentation on bravo
fid = fopen(sprintf('%s/tissues%s_job.m',names.directory_path,names.folder_id),'w+');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.channel(1).vols = {''%s/%s,1''};\n',names.directory_path,names.flair_coreg);
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.channel(1).biasreg = 0;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.channel(1).biasfwhm = 120;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.channel(1).write = [0 1];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.channel(2).vols = {''%s/%s,1''};\n',names.directory_path,names.source_bravo);
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.channel(2).biasreg = 0;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.channel(2).biasfwhm = 120;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.channel(2).write = [0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {''%s/tpm/TPM.nii,1''};\n',spmtoolbox_path);
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 5;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {''%s/tpm/TPM.nii,2''};\n',spmtoolbox_path);
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 5;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {''%s/tpm/TPM.nii,3''};\n',spmtoolbox_path);
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 5;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {''%s/tpm/TPM.nii,4''};\n',spmtoolbox_path);
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {''%s/tpm/TPM.nii,5''};\n',spmtoolbox_path);
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {''%s/tpm/TPM.nii,6''};\n',spmtoolbox_path);
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.warp.mrf = 2;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.025 0.1];\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.warp.affreg = ''mni'';\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;\n');
fprintf(fid,'matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];\n');fclose(fid);
%% tissue labels segmenting on bravo image
fprintf('GM, WM, CSF Tissues extraction from T1\n');
%
job = sprintf('%s/tissues%s_job.m',names.directory_path,names.folder_id);
if isdeployed
    if system(sprintf('%s batch %s', fullfile(spmtoolbox_path, 'spm12'), job)) ~= 0
        error('Could not intialize SPM12 preprocessing! \n\n  Make sure the toolbox path is correct!');
    end
else
    spm_jobman('run', {job});
end
clear job;

load(fullfile(names.w2mhstoolbox_path, 'Hyperparameters.mat'), 'delete_preproc');

if(strcmpi(delete_preproc, 'yes'))
    delete(sprintf('%s/c1rFLAIR_%s.nii',names.directory_path,names.folder_id));
    delete(sprintf('%s/coreg%s_job.m',names.directory_path,names.folder_id));
    numeldelete(sprintf('%s/tissues%s_job.m',names.directory_path,names.folder_id));
else
names.pve_flair_c1 = sprintf('c1rFLAIR_%s.nii',names.folder_id);
end
delete(sprintf('%s/rFLAIR_%s_seg8.mat',names.directory_path,names.folder_id));
names.pve_flair_c2 = sprintf('c2rFLAIR_%s.nii',names.folder_id);
names.pve_flair_c3 = sprintf('c3rFLAIR_%s.nii',names.folder_id);
names.bias_corr = sprintf('mrFLAIR_%s.nii',names.folder_id);

%% generating actual WM, GM and CSF images from the bia corrected and coregistered flair using pve labels of bravo
fprintf('Constructing the WM, GM and CSF templates\n');
wm_mask = load_nii(sprintf('%s/c2rFLAIR_%s.nii',names.directory_path,names.folder_id));
flair_ref = load_nii(sprintf('%s/mrFLAIR_%s.nii',names.directory_path,names.folder_id));
sz = size(flair_ref.img); nii = flair_ref;
wm_mask_new = wm_mask.img; wm_mask_new(wm_mask.img>0) = 1;
wm_template = flair_ref.img .* wm_mask_new;

%% generating partial volume estimates and ventricular maps
fprintf('Constructing PV Estimates and Ventricle template \n');
%
pve_cut = zeros(sz);
pve_cut(wm_mask.img==0) = 1;
vent_cut = zeros(sz);
conn = conndef(2, 'minimal');
for d3 = 1:sz(3)
    pve_slice = squeeze(pve_cut(:,:,d3));
    %vent_cut(:,:,d3) = single(pve_slice - regiongrowing(pve_slice,1,1));
    % A binary Image does not need regiongrowing
    cc = bwconncomp(pve_slice, conn);
    pve_slice(cc.PixelIdxList{1}) = 0;
    vent_cut(:,:,d3) = pve_slice;
end
nii.img = vent_cut; save_nii(nii,sprintf('%s/vent_cut_%s.nii',names.directory_path,names.folder_id));
[L_vent,num_vent] = bwlabeln(vent_cut); [hist_L_vent,xout] = hist(L_vent(:),unique(L_vent));
[sort_hist_L_vent, ref] = sort(hist_L_vent); 
L_vent(L_vent~=xout(ref(end-1))) = 0; L_vent(L_vent~=0) = 1;
%
nii.img = L_vent; save_nii(nii, sprintf('%s/Vent_strip_%s.nii',names.directory_path,names.folder_id));
names.Vent = sprintf('Vent_strip_%s.nii',names.folder_id);

% dilating ventricles and adding them to wm search
% areastrcmp(delete_preproc, 'yes')
[x,y,z] = ndgrid(-3:3); se = strel(sqrt(x.^2 + y.^2 + z.^2) <=3); vent_dil = imdilate(L_vent,se);
%nii.img = vent_dil; save_nii(nii, sprintf('%s/Vent_strip_%s.nii',names.directory_path,names.folder_id));
%names.Vent = sprintf('Vent_strip_%s.nii',names.folder_id);

%% modifying WM template using ventricle template
fprintf('Modifying WM template using Ventricle estimate \n');
%par
vent_template = flair_ref.img .* vent_dil; 
wm_template1 = wm_template; 
wm_template1(wm_template==0 & vent_template>0) = vent_template(wm_template==0 & vent_template>0);
nii.img = wm_template1; save_nii(nii, sprintf('%s/WM_modstrip_%s.nii',names.directory_path,names.folder_id));
names.WM_mod = sprintf('WM_modstrip_%s.nii',names.folder_id);

%% generated dilated ventricular maps for perventricular and deep hyperintensities separtion
fprintf('Constructing GM/CSF border map for post processing \n');
%
gc = pve_cut - vent_dil; gc(gc==-1) = 0;
nii.img = gc; save_nii(nii, sprintf('%s/GMCSF_strip_%s.nii',names.directory_path,names.folder_id));
names.GMCSF = sprintf('GMCSF_strip_%s.nii',names.folder_id);

%% saving the names file
save(sprintf('%s/names_%s.mat', names.directory_path, names.folder_id), 'names');

%% end
