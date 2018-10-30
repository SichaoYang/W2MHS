function ker = get_gauss_conv(K)


%Set up the smoothing kernel to filter out small local peaks.
CK = floor(K/2);
sigma = sqrt(CK);
ker = zeros(CK,CK,CK);
center = ceil(CK/2) * ones(1,3);
for i=1:CK
    for j=1:CK
        for k=1:CK
            ker(i,j,k) = exp(-norm([i j k] - center)/sigma);
        end
    end
end
ker = ker/sum(ker(:));




end