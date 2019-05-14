
%% script for postprocessing and quantifying hyperintensity segmentations

function obj = postproc(obj)

%% initializing and loading necessary files for postprocessing
    fprintf('\nPostprocessing and cleaning up the predicted WMH voxels of subject %s \n', obj.id);
    nii = load_nii(obj.ff(obj.names.class));  % classification confidence
    roi = load_nii(obj.ff(obj.names.roi)); roi_mask = roi.img > 0;  % ROI
    roi = double(roi.img); roi_norm = max(roi(:)); roi_normalized = roi / roi_norm;  % normalized ROI
    pmap = nii.img .* roi_normalized; pmap(pmap < obj.pmap_cut) = 0; pmap_mask = pmap > 0;  % "rectified" pmap
    clean_r = ceil(obj.clean_th); [x,y,z] = ndgrid(-clean_r:clean_r);
    se = strel(strel(sqrt(x.^2 + y.^2 + z.^2) <= clean_r));
    gmcsf_mask = imdilate(~roi_mask, se); periGM = pmap_mask & gmcsf_mask;  % peri-GM region
    vent_dil = load_nii(obj.ff(obj.names.vent_dil)); vent_mask = vent_dil.img > 0;  % periventricular region

    cc = bwconncomp(pmap_mask, 6);  % connected components in the current pmap
    for i = 1:numel(cc.PixelIdxList)
        l = cc.PixelIdxList{i};
        vol = sum(pmap_mask(l)); vol_periGM = sum(periGM(l));  % find the proportion of WMH in the peri-GM region
        if vol == 1 || (vol < 64 && vol_periGM / vol > 0.5), pmap(l) = 0; end  % clear the WMH component with more than half voxels in the peri-GM region
    end

    if obj.keeps.pmap, nii.img = pmap; save_nii(nii, obj.ff(obj.names.pmap)); end
    pmap_d_cut = pmap .* ~vent_mask;  % pmap outside the dilated periventricular region
    if obj.keeps.pmap_d_cut, nii.img = pmap_d_cut; save_nii(nii, obj.ff(obj.names.pmap_d_cut)); end
    pmap_p_cut = pmap .* vent_mask;  % pmap inside the dilated periventricular region
    if obj.keeps.pmap_p_cut, nii.img = pmap_p_cut; save_nii(nii, obj.ff(obj.names.pmap_p_cut)); end

    pmap_mask = pmap > 0;
    cc = bwconncomp(pmap_mask, 6);
    for i = 1:numel(cc.PixelIdxList)
        l = cc.PixelIdxList{i};  % add all voxels in WMH components connected to the periventricular region to the ventricular mask
        if any(vent_mask(l)), vent_mask(cc.PixelIdxList{i}) = 1; end
    end
    pmap_d_conn = pmap .* ~vent_mask;  % pmap isolated from the dilated periventricular region
    if obj.keeps.pmap_d_conn, nii.img = pmap_d_conn; save_nii(nii, obj.ff(obj.names.pmap_d_conn)); end
    pmap_p_conn = pmap .* vent_mask;  % pmap connected to the dilated periventricular region
    if obj.keeps.pmap_p_conn, nii.img = pmap_p_conn; save_nii(nii, obj.ff(obj.names.pmap_p_conn)); end
    fprintf('Done postprocessing of subject %s\n', obj.id);

%% quantification
    k = 1;  % Ithapu et al., 2014, p. 4226
    ref = load_nii(obj.ff(obj.names.bias_corr)); ICV = sum(ref.img, 'all');  % periventricular region
    EV = sum((roi_norm * pmap) .^ k, 'all') / ICV;
    dEV_cut = sum((roi_norm * pmap_d_cut) .^ k, 'all') / ICV;
    pEV_cut = sum((roi_norm * pmap_p_cut) .^ k, 'all') / ICV;
    dEV_conn = sum((roi_norm * pmap_d_conn) .^ k, 'all') / ICV;
    pEV_conn = sum((roi_norm * pmap_p_conn) .^ k, 'all') / ICV;
    
    if obj.keeps.quant_mat, save(obj.ff(obj.names.quant_mat), 'EV', 'dEV_cut', 'pEV_cut', 'dEV_conn', 'pEV_conn'); end
    summary = sprintf(['Subject: %s\nEV: %.9f\n', ...
        'dEV (outside periventricular region): %.9f\n', ...
        'pEV (inside periventricular region): %.9f\n', ...
        'dEV (isolated from periventricular region): %.9f\n', ...
        'pEV (connected to periventricular region): %.9f\n'], ...
        obj.id, EV, dEV_cut, pEV_cut, dEV_conn, pEV_conn);
    fprintf(summary);
    if obj.keeps.quant_txt
        fid = fopen(obj.ff(obj.names.quant_txt), 'w');
        fprintf(fid, summary);
        fclose(fid);
    end
    
%% clean unneeded nifti files
    obj.del('bias_corr'); obj.del('roi'); obj.del('vent_dil'); obj.del('class');
end
