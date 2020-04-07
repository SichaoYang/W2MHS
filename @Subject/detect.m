
%% script for segmenting hyperintensities on a new image given training outputs

function obj = detect(obj)

%% loading image data and options for training
if exist(obj.ff(obj.names.class), 'file'), return; end

roi = load_nii(obj.ff(obj.names.roi));
K = 5; width = [3, 5]; batch_size = obj.batch_size;
sub_image = padarray(roi.img(K+1:end-K,K+1:end-K,K+1:end-K), [K K K]);
sub_dim = size(sub_image);
[ker, width_vec] = getKernels(width);
load('model.mat', 'W1', 'W2', 'W3', 'W4', ...  % load parameters from a pre-trained Keras model
                  'b1', 'b2', 'b3', 'b4', ...
                  'gamma1', 'gamma2', 'gamma3', ...
                  'beta1', 'beta2', 'beta3', ...
                  'mean1', 'mean2', 'mean3', ...
                  'std1', 'std2', 'std3', 'epsilon');

%% segmenting new subject
% initializing the segmentation process
fg_thresh = 0.6 * max(sub_image(:));
fg = find(sub_image > fg_thresh); 
set_size = length(fg); batches = ceil(set_size / batch_size);
disp(['Segmenting subject ', obj.id])
fprintf('Batch size: %d  Total folds: %d\n', batch_size, batches)
oo = zeros(set_size,1); first = 1;
% computes kernels and classifies WMH
tic
for batch = 1:batches
    last = min(first + batch_size - 1, set_size);
    sub_ind = first:last;
    [Xr,Yr,Zr] = ind2sub(sub_dim, fg(sub_ind));
    D  = zeros(length(sub_ind), K^3);
    D2 = zeros(length(sub_ind), K^3 * length(ker));
    R  = -(K-1)/2:(K-1)/2;
    
    print_step = ceil(length(sub_ind) / 50);
    fprintf('fold %d =', batch);
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
        if mod(n, print_step) == 0, fprintf('\b=>'); end
    end
    
    %% forward propagation
    D3 = [D,D2];
    % X0 = gamma0 .* (D3 - mean0) ./ sqrt(std0 .^ 2 + epsilon) + beta0;  % column normalization
    X0 = D3 ./ vecnorm(D3')';  % row normalization: ||x|| = 1
    Z1 = X0 * W1 + b1;
    Z1 = gamma1 .* (Z1 - mean1) ./ sqrt(std1 .^ 2 + epsilon) + beta1;  % batch normalization
    A1 = max(Z1, 0);                   % relu activation
    Z2 = A1 * W2 + b2;
    Z2 = gamma2 .* (Z2 - mean2) ./ sqrt(std2 .^ 2 + epsilon) + beta2;  % batch normalization
    A2 = max(Z2, 0);                   % relu activation
    Z3 = A2 * W3 + b3;
    Z3 = gamma3 .* (Z3 - mean3) ./ sqrt(std3 .^ 2 + epsilon) + beta3;  % batch normalization
    A3 = max(Z3, 0);                   % relu activation
    Z4 = A3 * W4 + b4;
    out = 1 ./ (1 + exp(-Z4));
    oo(sub_ind) = 1 ./ (1 + exp(-Z4));
    
    first = last + 1;
    fprintf('[%d/%d] done\n', last, set_size);
    toc
end
disp('... all folds done ...');
out = zeros(sub_dim); out(ind2sub(sub_dim, fg)) = oo;
roi.img = out; save_nii(roi, obj.ff(obj.names.class));

end