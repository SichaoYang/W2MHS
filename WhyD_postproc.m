
%% script for postprocessing and cleaning up the hyperintensity segmentations

%%
function names = WhyD_postproc(names, clean_th)

%% initializing and loading necessary files for postprocessing
load(fullfile(names.w2mhstoolbox_path, 'Hyperparameters.mat'), 'clean_th', 'pmap_cut', 'delete_preproc');
if ~exist('clean_th','var'), clean_th = 2.5; end
input = load_nii(fullfile(names.directory_path, names.seg_out));
out = double(input.img);
sz = size(out);
ref_input = load_nii(fullfile(names.directory_path, names.WM_mod));
ref_im = rescale(double(ref_input.img));
gc_input = load_nii(fullfile(names.directory_path, names.GMCSF));
gc = double(gc_input.img);

%% triggering the postprocessing
fprintf('Post processing and cleaning up the segmented outputs of subject : %s_%s \n', names.folder_name, names.folder_id);
print_short = 'DNN';

out_unrectify = out .* ref_im; out_pos = zeros(sz);

% cleaning up noisy detections
for d3 = 1:sz(3)
    temp = squeeze(gc(:,:,d3)); temp_bd = bwboundaries(1-temp); vert_bd = [];
    for c = 1:length(temp_bd), vert_bd = [vert_bd;temp_bd{c,1}]; end
    if isempty(vert_bd), continue; end
    isl = squeeze(out_unrectify(:,:,d3));
    isl_bin = isl; isl_bin(isl >= 0.5) = 1; isl_bin(isl < 0.5) = 0;  % Binarization
    [L_isl,num_isl] = bwlabel(isl_bin);  % Label connected components in 2-D binary image
   
    for i = 1:num_isl
        [p,q] = ind2sub(sz(1:2),find(L_isl == i));
        if length(p) == 1, isl(p,q) = 0;
        else
            distmat12 = zeros(length(p),length(vert_bd),2); distmat34 = distmat12;
            distmat12(:,:,1) = repmat(p, 1, length(vert_bd));
            distmat12(:,:,2) = repmat(q, 1, length(vert_bd));
            distmat34(:,:,1) = repmat(vert_bd(:,1)', length(p), 1);
            distmat34(:,:,2) = repmat(vert_bd(:,2)', length(p), 1);
            dist = min(sqrt(sum((distmat12-distmat34) .* (distmat12-distmat34), 3)), [], 2);
            if length(p) < 100 && length(find(dist <= clean_th)) / length(p) > 0.5
                for m = 1:1:length(p), isl(p(m),q(m)) = 0; end
            end
        end
    end
    out_pos(:,:,d3) = isl;
end

input.img = out_unrectify;
save_nii(input, sprintf('%s/%s_unrectify_%s.nii', names.directory_path, print_short, names.folder_id));
names.seg_unrectify = sprintf('%s_unrectify_%s.nii', print_short, names.folder_id);

input.img = out_pos; save_nii(input, sprintf('%s/%s_pmap_%s.nii', names.directory_path, print_short, names.folder_id));
names.seg_pmap = sprintf('%s_pmap_%s.nii', print_short, names.folder_id);
save(sprintf('%s/names_%s.mat', names.directory_path, names.folder_id),'names');
fprintf('Done postprocessing and cleaning up of subject : %s_%s \n', names.folder_name, names.folder_id);
if strcmpi(delete_preproc, 'yes')
    delete(fullfile(names.directory_path, names.GMCSF));
end
%% end