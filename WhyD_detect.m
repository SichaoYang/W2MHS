
%% script for segmenting hyperintensities on a new image given training outputs

function names = WhyD_detect(names, training_path)

%% loading image data and options for training
input = load_nii(fullfile(names.directory_path, names.WM_mod));
load(fullfile(training_path, 'options_training.mat'), 'width', 'K');
sub_image = padarray(input.img(K+1:end-K,K+1:end-K,K+1:end-K), [K K K]);
sub_dim = size(sub_image);
[ker, width_vec] = getKernels(width);

[~,~]=system('docker stop w2mhs');
[~,~]=system('docker rm w2mhs');
system(sprintf('docker create -t -v "%s":/training --name w2mhs sichao/w2mhs:v2018.3 python', training_path));
system('docker start w2mhs');
%% segmenting new subject
% initializing the segmentation process
load(fullfile(names.w2mhstoolbox_path, 'Hyperparameters.mat'), 'fold_size');
fg_thresh = 0.6 * max(sub_image(:));
fg = find(sub_image > fg_thresh); 
N_tot = length(fg); folds = ceil(N_tot/fold_size);
names.method = 'DNN Classification';
print = struct('name', 'DNN Classification', 'short', 'DNN');
fprintf('Segmenting subject: %s_%s using %s.\n', names.folder_name, names.folder_id, print.name);
fprintf('Fold size: %d. Total folds in processing: %d \n', fold_size, folds);
oo = zeros(N_tot,1); first = 1;
feature_path = fullfile(training_path, 'feature_set.csv');
label_path = fullfile(training_path, 'DNN_testing_file.csv');
print_step = min(10, ceil(folds/5));
% computing kernels for each fold followed by segmenting
tic
for j = 1:folds
    last = min(first + fold_size - 1, N_tot);
    sub_ind = first:last;
    [Xr,Yr,Zr] = ind2sub(sub_dim, fg(sub_ind));
    D  = zeros(length(sub_ind), K^3);
    D2 = zeros(length(sub_ind), K^3 * length(ker));
    R  = -(K-1)/2:(K-1)/2;
    for n = 1:length(sub_ind)
        local = sub_image(Xr(n) + R,Yr(n) + R,Zr(n) + R);
        D(n,:) = local(:);
        for k = 1:length(ker)
            r = (k-1)*K^3+1:k*K^3;
            conv = convn(local, ker{k,1}, 'same');
            D2(n,r) = conv(:) / width_vec(k)^3;
            if k == length(ker),      D2(n,r) = D2(n,r) / 3;
            elseif 3 <= k && k <= 8,  D2(n,r) = D2(n,r) + D(n,:);
            elseif 9 <= k && k <= 14, D2(n,r) = D2(n,r) - D(n,:);
            end
        end
    end
    D3 = [D,D2];
    % writes the features to the file for testing purposes
    csvwrite(fullfile(training_path, 'feature_set.csv'), D3);
    % executes the testing script
    system('docker exec -t w2mhs python W2MHS_testing.py');
    % converts the binary label output from string to integer 
    oo(sub_ind) = csvread(label_path);
    
    first = last + 1;
    if mod(j, print_step) == 0
        fprintf('... %d done ... \n',j);
        toc
    end
end
fprintf('... all folds done ... \n');
system('docker stop w2mhs');
system('docker rm w2mhs');
delete(label_path);
delete(feature_path);

fprintf('Done segmenting subject : %s_%s using %s method \n', names.folder_name, names.folder_id, print.name);
out = zeros(sub_dim); out(ind2sub(sub_dim, fg)) = oo;
% saving the segmentated output and updating names file
nii = input; nii.img = out;
names.seg_out = sprintf('%s_out_%s.nii', print.short, names.folder_id);
save_nii(nii, fullfile(names.directory_path, names.seg_out));
save(sprintf('%s/names_%s.mat', names.directory_path, names.folder_id), 'names');

%% end