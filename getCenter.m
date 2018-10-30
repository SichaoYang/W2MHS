% training features creation - centers of WMHIs
function [C C_tot C_minus C_minus_tot fg_thresh labels features_int C_pos_neg] = getCenter(sub_pmap,sub_image,sub_dim,K);

th1 = 0.5; th2 = 0.1; %N = 150000;
%[jnk ind] = sort(sub_image(:));
fg_thresh = 0.6*max(sub_image(:));%sub_image(ind(end-N));
%neg_offset = 5; pos_offset = 2; pos_count = 1;
checking = 1; index = 1; % wide = 3;
% clear diff;
% diff1 = [-1 -1;-1 0;-1 1;0 -1;0 0;0 1;1 -1;1 0;1 1];
% diff2 = [-1*ones(9,1),diff1];
% diff3 = [zeros(9,1),diff1];
% diff4 = [1*ones(9,1),diff1];
% diff = [diff2;diff3;diff4];
% clear diff1 diff2 diff3 diff4;
[d1 d2 d3] = ndgrid(-(K-1)/2:(K-1)/2, -(K-1)/2:(K-1)/2, -(K-1)/2:(K-1)/2);
diff = [d1(:) d2(:) d3(:)];

[L, NUM] = bwlabeln(sub_pmap > th1);
C = []; C_tot = [];
C_minus = []; C_minus_tot = [];
while checking == 1;
    [X Y Z] = ind2sub(sub_dim,find(L==index));
    for m = 1:1:length(X)
        XYZd = repmat([X(m) Y(m) Z(m)],size(diff,1),1) + diff;
        tf = ismember(XYZd,[X Y Z],'rows');
%         chks = zeros(size(diff,1),1);
%         for n = 1:1:size(diff,1)
%             chks(n,1) = sub_image(XYZd(n,1),XYZd(n,2),XYZd(n,3));
%         end
        if sum(tf)>=0.3*size(diff,1) && sub_image(X(m),Y(m),Z(m))>fg_thresh
            C = [C;[X(m) Y(m) Z(m)]];
            C_tot = [C_tot;XYZd];
            %         end
%         elseif sum(tf)<=0.1*size(diff,1) && sub_image(X(m),Y(m),Z(m))>fg_thresh
%             C_minus = [C_minus;[X(m) Y(m) Z(m)]];
%             C_minus_tot = [C_minus_tot;XYZd];
        end
    end
    index = index + 1;
    if index == NUM checking = 0; end
end
C_tot = unique(C_tot,'rows');
clear X Y Z checking index;

% Is1 = find(sub_image>0);
% Is2 = find(sub_image>fg_thresh);
% Ip = find(sub_pmap>th2);
% Id = setdiff(setdiff(Is1,Is2),Ip);
% [Xd Yd Zd] = ind2sub(sub_dim,Id);
% sub_pmap_th = sub_pmap;
% sub_pmap_th(sub_pmap>th2) = 0;
% sub_pmap_th(sub_pmap<0.1*th2) = 0;
% [L, NUM] = bwlabeln(sub_pmap_th > 0);

[jnk ink] = sort(sub_image(:));
fg = ink(find(jnk>0,1,'first'):end);
[jnk ink1] = sort(sub_pmap(:));
fg_p = ink1(1:find(jnk<th2,1,'last'));
[Xd Yd Zd] = ind2sub(sub_dim,intersect(fg,fg_p));
Cnum = size(C,1);% - size(C_minus,1);
checking = 1; j = 1;
index = randperm(length(fg)); 
while Cnum > 0 && checking == 1
%     [X Y Z] = ind2sub(sub_dim,find(L==index(j)));
    [Xr Yr Zr] = ind2sub(sub_dim,fg(j));
    XYZrd = repmat([Xr Yr Zr],size(diff,1),1) + diff;
%     for m = 1:1:length(X)
%         XYZd = repmat([X(m) Y(m) Z(m)],size(diff,1),1) + diff;
        tf = ismember(XYZrd,[Xd Yd Zd],'rows');
%         chks = zeros(size(diff,1),2);
%         for n = 1:1:size(diff,1)
%             chks(n,1) = sub_image(XYZrd(n,1),XYZrd(n,2),XYZrd(n,3)) - ;
%             chks(n,2) = sub_pmap(XYZrd(n,1),XYZrd(n,2),XYZrd(n,3)) - ;
%         end
        if sum(tf) >= 0.7*size(diff,1) && sub_image(Xr,Yr,Zr)<0.5*fg_thresh
            C_minus = [C_minus;[Xr Yr Zr]]; fprintf('.');
            C_minus_tot = [C_minus_tot;XYZrd];
            Cnum = Cnum - 1;
        end
%         if Cnum == 0 continue; end
%     end
    j = j + 1;
    if j>length(fg) checking = 0; end
end
% C_minus_tot = unique(C_minus_tot,'rows');

C_pos_neg = [C;C_minus];
%if K~=3 || size(diff,1)~=K^3 error('Ok! I only take K=3'); end
labels = zeros(length(C),1) + 1;
labels = [labels;zeros(length(C_minus),1) - 1];
features_int = zeros(length(labels),K^3);
for l = 1:1:length(labels)
    i1_1 = C_pos_neg(l,1)-(K-1)/2; i1_2 = C_pos_neg(l,1)+(K-1)/2;
    i2_1 = C_pos_neg(l,2)-(K-1)/2; i2_2 = C_pos_neg(l,2)+(K-1)/2;
    i3_1 = C_pos_neg(l,3)-(K-1)/2; i3_2 = C_pos_neg(l,3)+(K-1)/2; 
    tempim = sub_image(i1_1:i1_2,i2_1:i2_2,i3_1:i3_2);
    features_int(l,:) = reshape(tempim,1,[]);
end


% % L_NUM = zeros(NUM,1);
% % M_NUM = zeros(NUM,1);
% % for l = 1:1:NUM
% %     [X,Y,Z] = ind2sub(size(L),find(L==l));
% %     L_NUM(l,1) = length(X);
% %     M_NUM(l,1) = mean(mean(mean(sub_pmap(X,Y,Z))));
% % end
% % Compute WMHI centers (C)
% % C_minus = zeros(7*NUM,3);
% % rng = zeros(3,1);
% % pos_count = 1;
% for i=1:7:(NUM*7)-7
%     % Bounding box around one WMHI
%     I = find(L==((i-1)/7+1));
%     [X,Y,Z] = ind2sub(size(L),I);
%     region_points = [X Y Z];
%     % Compute the boundary of L
%     boundary=[min(region_points); max(region_points)];
%     if max(size(boundary))<3, continue; end  % Skip single voxel
%     % Take max intensity in the WMHI for one training example
%     A = sub_pmap(boundary(1,1):boundary(2,1),boundary(1,2):boundary(2,2),boundary(1,3):boundary(2,3));
%     if numel(I) < 125 || min(size(A)) < 4, continue; end  % Skip small regions
%     [I,J] = max(A(:));
%     [X1,Y1,Z1] = ind2sub(size(A),J(1));
%     C(pos_count,:) = [X1 Y1 Z1] + boundary(1,:) - 1;
%     pos_count = pos_count+1;
%     % Pick the postive centers.
%     for d1=1:pos_offset:(boundary(2,1)-boundary(1,1))
%         for d2=1:pos_offset:(boundary(2,2)-boundary(1,2))
%             for d3=1:pos_offset:(boundary(2,3)-boundary(1,3))
%                 % Filtering the voxels in the bounding box
%                 if L(boundary(1,1)+d1-1,boundary(1,2)+d2-1,boundary(1,3)+d3-1)==((i-1)/7+1)
%                     C(pos_count,:) =  boundary(1,:) + [d1 d2 d3] - 1;
%                     pos_count = pos_count+1;
%                 end
%             end
%         end
%     end
%     C_minus(i+1,:) = get_one(find(X == boundary(2,1)), region_points, neg_offset, 1, sub_pmap);
%     C_minus(i+2,:) = get_one(find(X == boundary(1,1)), region_points, -neg_offset, 1, sub_pmap);
%     C_minus(i+3,:) = get_one(find(Y == boundary(2,2)), region_points, neg_offset, 2, sub_pmap);
%     C_minus(i+4,:) = get_one(find(Y == boundary(1,2)), region_points, -neg_offset, 2, sub_pmap);
%     C_minus(i+5,:) = get_one(find(Z == boundary(2,3)), region_points, neg_offset, 3, sub_pmap);
%     C_minus(i+6,:) = get_one(find(Z == boundary(1,3)), region_points, -neg_offset, 3, sub_pmap);
% end
% sizeC=size(C);
% 
% %Set up the context grid to create a 1D vector of offsets from the 3D
% %image. (offs)
% [x,y,z] = ndgrid(-(K-1)/2:(K-1)/2, -(K-1)/2:(K-1)/2, -(K-1)/2:(K-1)/2);
% I = [x(:) y(:) z(:)];
% V = [1; sub_dim(1); sub_dim(1)*sub_dim(2)];
% offs = I * V;
% clear I V x y z;
% 
% %Generate positive examples (train_set)
% C(sum(C,2) == 0,:) = []; %delete unpopulated examples
% %pos_features = train_to_features(C, offs, sub_image);
% 
% % %Generate negative examples near the hyperintensity boundary (train_set)
% C_minus(sum(C_minus,2) == 0,:) = []; %delete unpopulated examples
% %neg_boundary_features = train_to_features(C_minus, offs, sub_image);
% 
% %5 positives and 5 negatives per WMHI
% %train_features = [pos_features; neg_boundary_features; neg_features];
% %labels = ones(size(train_features,1),1);
% %labels((size(pos_features,1)+1):end) = -1;
% end
% 
% 
% function C = get_one(m, region_points, offset, i, sub_pmap)
% m = m(1);
% C = region_points(m,:) - 1;
% C(i) = C(i) + offset;
% if sub_pmap(C(1), C(2), C(3)) > 0.3, C(:) = 0; end
% end


