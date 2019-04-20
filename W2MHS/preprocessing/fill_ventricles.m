function vent_mask = fill_ventricles(wm_mask, gm_mask, csf_mask)
    tic;
    disp('  Extracting ventricles geometrically from WM mask:')
    rounds = 2;
    [sz1,sz2,sz3] = size(wm_mask);
    bg = ~wm_mask;
    for r = 1:rounds
        fprintf('    round %d =', r);
        print_step = ceil(sz1 / 10);
        for d1 = 1:sz1
            slice = squeeze(bg(d1,:,:));
            cc = bwconncomp(slice, 4);
            slice = zeros(size(slice));
            slice(cc.PixelIdxList{1}) = 1;
            bg(d1,:,:) = slice;
            if mod(d1, print_step) == 0, fprintf('\b=>'); end
        end
        print_step = ceil(sz2 / 10);
        for d2 = 1:sz2
            slice = squeeze(bg(:,d2,:));
            cc = bwconncomp(slice, 4);
            slice = zeros(size(slice));
            slice(cc.PixelIdxList{1}) = 1;
            bg(:,d2,:) = slice;
            if mod(d2, print_step) == 0, fprintf('\b=>'); end
        end
        print_step = ceil(sz3 / 10);
        for d3 = 1:sz3
            slice = squeeze(bg(:,:,d3));
            cc = bwconncomp(slice, 4);
            slice = zeros(size(slice));
            slice(cc.PixelIdxList{1}) = 1;
            bg(:,:,d3) = slice;
            if mod(d3, print_step) == 0, fprintf('\b=>'); end
        end
        toc;
    end
    fprintf('  Constructing ventricular mask: ')
    cc = bwconncomp(~wm_mask & ~bg, 6);
    [~, idx] = max(cellfun(@numel, cc.PixelIdxList));
    vent_mask = zeros(size(wm_mask));
    vent_mask(cc.PixelIdxList{idx}) = 1;
    vent_mask = vent_mask > 0;
    toc;
    fprintf('  Patching up ventricular mask with CSF mask: ')
    csf_mask(vent_mask) = 0;
    cc = bwconncomp(csf_mask, 6);
    [~, idx] = max(cellfun(@numel, cc.PixelIdxList));
    csf_mask(cc.PixelIdxList{idx}) = 0;
    csf_mask(vent_mask) = 1;
    cc = bwconncomp(csf_mask, 6);
    [~, idx] = max(cellfun(@numel, cc.PixelIdxList));
    vent_mask(cc.PixelIdxList{idx}) = 1;
    vent_mask = vent_mask > 0;
    toc;
    
    disp('  Patching up ventricular mask with WM mask & GM mask:')
    vent_mask_bkp = vent_mask;
    for dil_r = 3:2:7
        vent_mask = vent_mask_bkp;
        fprintf('    Blocking straight sinus by dilating the mask by %d voxels\n', dil_r);
        for r = 1:rounds
            fprintf('      round %d =', r);
            bg = ~(wm_mask | gm_mask);
            bg_dil = ~(imdilate(wm_mask | gm_mask, strel('disk', dil_r - 1)) | vent_mask);
            print_step = ceil(sz1 / 10);
            for d1 = 1:sz1
                slice = bwlabel(squeeze(bg_dil(d1,:,:)), 4);
                vent_dil = imdilate(squeeze(vent_mask(d1,:,:)), strel('disk',1));
                labels = unique(slice(vent_dil));
                for i = 1:numel(labels)
                    if labels(i) > 1
                        vent_slice = vent_mask(d1,:,:);
                        bg_slice = squeeze(bg(d1,:,:));
                        vent_slice(bg_slice & imdilate(slice == labels(i), strel('disk', dil_r))) = 1;
                        vent_mask(d1,:,:) = vent_slice;
                    end
                end
                if mod(d1, print_step) == 0, fprintf('\b=>'); end
            end
            print_step = ceil(sz2 / 10);
            for d2 = 1:sz2
                slice = bwlabel(squeeze(bg_dil(:,d2,:)), 4);
                vent_dil = imdilate(squeeze(vent_mask(:,d2,:)), strel('disk',1));
                labels = unique(slice(vent_dil));
                for i = 1:numel(labels)
                    if labels(i) > 1
                        vent_slice = vent_mask(:,d2,:);
                        bg_slice = squeeze(bg(:,d2,:));
                        vent_slice(bg_slice & imdilate(slice == labels(i), strel('disk', dil_r))) = 1;
                        vent_mask(:,d2,:) = vent_slice;
                    end
                end
                if mod(d2, print_step) == 0, fprintf('\b=>'); end
            end
            print_step = ceil(sz3 / 10);
            for d3 = 1:sz3
                slice = bwlabel(squeeze(bg_dil(:,:,d3)), 4);
                vent_dil = imdilate(squeeze(vent_mask(:,:,d3)), strel('disk',1));
                labels = unique(slice(vent_dil));
                for i = 1:numel(labels)
                    if labels(i) > 1
                        vent_slice = vent_mask(:,:,d3);
                        bg_slice = squeeze(bg(:,:,d3));
                        vent_slice(bg_slice & imdilate(slice == labels(i), strel('disk', dil_r))) = 1;
                        vent_mask(:,:,d3) = vent_slice;
                    end
                end
                if mod(d3, print_step) == 0, fprintf('\b=>'); end
            end
            toc;
        end
        vol_new = sum(vent_mask(:)); vol_old = sum(vent_mask_bkp(:));
        vol_chg = (vol_new - vol_old) / vol_old;
        fprintf('    Ventricular mask enlarged by %2.4f%%. ', vol_chg * 100);
        if (vol_new - vol_old) / vol_old < 0.05, break; end
        if dil_r < 7, fprintf('Too much!\n    Discard current patches. Increase dilation radius by 2 voxels.\n');
        else, fprintf('Too much!\n    Skip this step.');
        end
    end
    fprintf('\n  Ventricular mask created successfully.\n');
end