
%% script for quantifying the segmented hyperintensities

% this script is triggered if the argument do_quantify is 'yes'

%%
function obj = quant(obj)

%% initializing and loading necessary files for quantification
vent_input = load_nii(fullfile(names.directory_path,names.Vent));
pmap_input = load_nii(fullfile(names.directory_path,names.seg_pmap));
vent = double(vent_input.img);
pmap = double(pmap_input.img);

V_res = 0.5; % resolution of each voxel (in mm)
dist_D_P = 8; % periventricular region width (in mm)
[x,y,z] = ndgrid(-dist_D_P:dist_D_P); 
se = strel(sqrt(x.^2 + y.^2 + z.^2) <=dist_D_P/V_res); vent_dil = imdilate(vent,se);
gamma = 1; 

%% triggering the quantification
fprintf('Quantifying segmentations of Subject : %s_%s \n',names.folder_name,names.folder_id);
EV = V_res * sum(sum(sum(pmap.^gamma)));
% calculating EV measures of deep and periventricular detections
pmap_D = pmap .* (1-vent_dil); pmap_P = pmap .* vent_dil;
EV_D = V_res * sum(sum(sum(pmap_D.^gamma)));
EV_P = V_res * sum(sum(sum(pmap_P.^gamma)));

save(sprintf('%s/Quant_%s.mat',names.directory_path,names.folder_id),'EV','EV_D','EV_P');
names.accumulation = sprintf('Quant_%s.mat',names.folder_id);
save(sprintf('%s/names_%s.mat',names.directory_path,names.folder_id),'names');
names.ev_measures = sprintf('%s/%s_Quant_%s.mat',names.directory_path,'RFREG',names.folder_id);

% Print results to text file
fid = fopen(sprintf('%s/%s_ev_%s.txt',names.directory_path,'RFREG',names.folder_id), 'w');
fprintf(fid, ...
    'Study: %s  Subject: %s \n EV: %f \n EV-Deep: %f  \n EV-Periventricular: %f', ...
    names.folder_name, names.folder_id, EV, EV_D, EV_P);
fclose(fid);

% Delete preprocessing files if hyperparemeter is set

if strcmpi(delete_preproc, 'yes')
    delete(fullfile(names.directory_path,names.WM_mod));
    delete(fullfile(names.directory_path,names.Vent));
    delete(fullfile(names.directory_path,names.source_bravo));
    delete(fullfile(names.directory_path,names.source_flair));
    delete(fullfile(names.directory_path,names.pve_flair_c2));
    delete(fullfile(names.directory_path,names.pve_flair_c3));
 end

%% end
