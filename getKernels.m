.% kernels
function [ker, width_vec] = getKernels(width)

or = 3; wd = length(width);
ker = cell(2+2*or*wd+1,1);
width_vec = zeros(size(ker,1),1);

% gaussian filter

ind = find(width==3);
var = (2.5*sqrt(width(ind)))^2;
[x y z] = meshgrid(1:width(ind),1:width(ind),1:width(ind));
x = x - width(ind)/2 - 1/2;
y = y - width(ind)/2 - 1/2;
z = z - width(ind)/2 - 1/2;
r = x.^2 + y.^2 + z.^2;
ker_g = exp(-r/(2*var));
ker{1,1} = ker_g;
width_vec(1,1) = width(ind);

% laplacian filter

ind = find(width==5);
var = (1.095*sqrt(width(ind)))^2;
[x y z] = meshgrid(1:width(ind),1:width(ind),1:width(ind));
x = x - width(ind)/2 - 1/2;
y = y - width(ind)/2 - 1/2;
z = z - width(ind)/2 - 1/2;
r = x.^2 + y.^2 + z.^2;
ker_log = ((r-3*var)/var^2).*exp(-r/(2*var));
ker_log = (2/(abs(max(ker_log(:)))+abs(min(ker_log(:)))))*(ker_log+(abs(min(ker_log(:)))-abs(max(ker_log(:))))/2);
ker{2,1} = ker_log;
width_vec(2,1) = width(ind);

% sobel filter

h = [1 2 1]; h1 = [-1 0 1]; ks = cell(3,1);
temp = zeros(3,3);temp2 = zeros(3,3,3);
for d1 = 1:1:3
    for d2 = 1:1:3
        temp(d1,d2) = h(d1)*h(d2);
    end
end
temp2(:,:,1) = temp*h1(1);temp2(:,:,2) = temp*h1(2);temp2(:,:,3) = temp*h1(3);
ks{1,1} = temp2;
temp = zeros(3,3);temp2 = zeros(3,3,3);
for d1 = 1:1:3
    for d2 = 1:1:3
        temp(d1,d2) = h(d1)*h(d2);
    end
end
temp2(:,1,:) = temp*h1(1);temp2(:,2,:) = temp*h1(2);temp2(:,3,:) = temp*h1(3);
ks{2,1} = temp2;
temp = zeros(3,3);temp2 = zeros(3,3,3);
for d1 = 1:1:3
    for d2 = 1:1:3
        temp(d1,d2) = h(d1)*h(d2);
    end
end
temp2(:,1,:) = temp*h1(1);temp2(:,2,:) = temp*h1(2);temp2(:,3,:) = temp*h1(3);
ks{3,1} = temp2;
temp3 = zeros(size(temp2));
for dd = 1:3
    temp3 = temp3 + ks{dd,1}.*ks{dd,1};
end
ker{end,1} = sqrt(temp3);
width_vec(end,1) = 3;

% difference of gaussians

for wdind = 1:1:wd
    vararr = ([0.5,1.1,1.75,2.5]*sqrt(width(wdind))).^2;
    for t = 2:length(vararr)
        var = vararr(t-1); % shud be odd
        [x y z] = meshgrid(1:width(wdind),1:width(wdind),1:width(wdind));
        x = x - width(wdind)/2 - 1/2;
        y = y - width(wdind)/2 - 1/2;
        z = z - width(wdind)/2 - 1/2;
        r = x.^2 + y.^2 + z.^2;
        k1 = exp(-r/(2*var));
        var = vararr(t); % shud be odd
        k2 = exp(-r/(2*var));
        ker{2+(wdind-1)*or+(t-1),1} = k2-k1;
        width_vec(2+(wdind-1)*or+(t-1),1) = width(wdind);
    end
end

% difference of laplacians

for wdind = 1:1:wd
    vararr = ([0.75,0.95,1.2,1.4]*sqrt(width(wdind))).^2;
    for t = 2:length(vararr)
        var = vararr(t-1); % shud be odd
        [x y z] = meshgrid(1:width(wdind),1:width(wdind),1:width(wdind));
        x = x - width(wdind)/2 - 1/2;
        y = y - width(wdind)/2 - 1/2;
        z = z - width(wdind)/2 - 1/2;
        r = x.^2 + y.^2 + z.^2;
        k1 = ((r-3*var)/var^2).*exp(-r/(2*var));
        k1 = (2/(abs(max(k1(:)))+abs(min(k1(:)))))*(k1+(abs(min(k1(:)))-abs(max(k1(:))))/2);
        var = vararr(t); % shud be odd
        k2 = ((r-3*var)/var^2).*exp(-r/(2*var));
        k2 = (2/(abs(max(k2(:)))+abs(min(k2(:)))))*(k2+(abs(min(k2(:)))-abs(max(k2(:))))/2);
        ker{2+or*wd+(wdind-1)*or+(t-1),1} = k2-k1;
        width_vec(2+or*wd+(wdind-1)*or+(t-1),1) = width(wdind);
    end
end
