
%% script for preprocessing the raw T1 and T2 input files

function obj = preproc(obj)
%% check existing output files needed by following steps
if (~obj.do_preproc && ...
        exist(obj.ff(obj.names.roi), 'file') && ...
        exist(obj.ff(obj.names.vent_dil), 'file'))
    fprintf('\nSubject %s already has expected output files. Skip preprocessing.\n', obj.id);
    return;
else
    fprintf('\nPreprocessing subject %s\n', obj.id);
end

%% initialize spm
tpm_path = fullfile(obj.spm_path, 'tpm', 'TPM.nii');
if ~exist(tpm_path, 'file')
    error('Could not find tpm/TPM.nii under SPM Toolbox Path!');
end
addpath(obj.spm_path);
spm('defaults','fmri');
% spm_jobman('initcfg');

%% coregister flair image to T1
fprintf('\nCoregistering T2-FLAIR to T1:\n');
if (obj.do_preproc || ~exist(obj.ff(obj.names.coreg), 'file'))
    coregister(obj.ff(obj.names.t1), obj.ff(obj.names.t2));
    movefile(obj.ff(['r' obj.names.t2]), obj.ff(obj.names.coreg));
else
    disp('Expected coregistration output found. Skip this step.')
end
    
%% segment WM, GM and CSF partial volume estimates from coregistered flair using pve labels from T1
fprintf('\nSegmenting GM, WM and CSF PVEs and correcting bias of T2:\n');
if (obj.do_preproc || ...
        ~exist(obj.ff(obj.names.gm), 'file') || ...
        ~exist(obj.ff(obj.names.wm), 'file') || ...
        ~exist(obj.ff(obj.names.csf), 'file') || ...
        ~exist(obj.ff(obj.names.bias_corr), 'file'))
    segment(obj.ff(obj.names.coreg), obj.ff(obj.names.t1), tpm_path);
    delete(obj.ff([obj.names.coreg(1:end-4), '_seg8.mat']));
    movefile(obj.ff(['c1' obj.names.coreg]), obj.ff(obj.names.gm));   % Grey Matter PVE
    movefile(obj.ff(['c2' obj.names.coreg]), obj.ff(obj.names.wm));   % White Matter PVE
    movefile(obj.ff(['c3' obj.names.coreg]), obj.ff(obj.names.csf));  % CerebroSpinal Fluid PVE
    movefile(obj.ff(['m' obj.names.coreg]), obj.ff(obj.names.bias_corr));  % bias corrected T2
else
    disp('Expected segmentation output found. Skip this step.')
end

wm_mask  = load_nii(obj.ff(obj.names.wm));  wm_mask  = wm_mask.img  > 0;
gm_mask  = load_nii(obj.ff(obj.names.gm));  gm_mask  = gm_mask.img  > 0;
csf_mask = load_nii(obj.ff(obj.names.csf)); csf_mask = csf_mask.img > 0;
ref = load_nii(obj.ff(obj.names.bias_corr)); nii = ref;

obj.del('t1'); obj.del('t2'); obj.del('coreg'); obj.del('wm'); obj.del('gm'); obj.del('csf');

%% extract ventricular mask
fprintf('\nExtracting ventricular mask:\n');
if (obj.do_preproc || ~exist(obj.ff(obj.names.vent), 'file'))
    vent_mask = fill_ventricles(wm_mask, gm_mask, csf_mask);
    if obj.keeps.vent, nii.img = vent_mask; save_nii(nii, obj.ff(obj.names.vent)); end
else
    nii = load_nii(obj.ff(obj.names.vent)); vent_mask = nii.img > 0;
    disp('Expected ventricular mask output found. Skip this step.');
end

%% dilate ventricular mask
fprintf('\nDilating ventricular mask:\n');
if (obj.do_preproc || ~exist(obj.ff(obj.names.vent_dil), 'file'))
    tic;
    vent_dil = imdilate(vent_mask, strel('disk', obj.vent_dil_r));
    nii.img = vent_dil;  save_nii(nii, obj.ff(obj.names.vent_dil));
    toc;
else
    nii = load_nii(obj.ff(obj.names.vent_dil)); vent_dil = nii.img > 0;
    disp('Expected dilated ventricular mask output found. Skip this step.');
end

%% complement WM template using ventricular template
fprintf('\nConstructing ROI combining WM and ventricular estimates:\n');
if (obj.do_preproc || ~exist(obj.ff(obj.names.roi), 'file'))
    tic;
    nii.img = ref.img .* (vent_dil | wm_mask);
    save_nii(nii, obj.ff(obj.names.roi));
    toc;
else
    disp('Expected ROI output found. Skip this step.');
end

%% Done
fprintf('\nDone preprocessing subject %s\n', obj.id);

end
