classdef Visual    
    methods (Static)
        function init(underlay_nii, overlay_nii, dual_disp)
            if ischar(underlay_nii), underlay_nii = load_nii(underlay_nii); end
            if dual_disp, Visual.underlay(underlay_nii, overlay_nii, dual_disp); end
            if ischar(overlay_nii), overlay_nii = load_nii(overlay_nii); end
            Visual.overlay(underlay_nii, overlay_nii, dual_disp);
        end
        
        function handle = underlay(underlay_nii, ~, dual_disp)
            persistent h;
            if nargin > 1
                options.setcolorindex = 3;
                if dual_disp, options.setbuttondown = 'Visual.underlay_onclick'; end
                h = view_nii(underlay_nii, options);
            elseif nargin == 1
                h = underlay_nii;
            end
            handle = h;
        end
        
        function handle = overlay(underlay_nii, overlay_nii, dual_disp)
            persistent h;
            if nargin > 1
                options.glblocminmax = [0 1];
                options.setcolorindex = 4;
                if dual_disp, options.setbuttondown = 'Visual.overlay_onclick'; end
                options.setvalue.idx = find(overlay_nii.img > 0);
                options.setvalue.val = overlay_nii.img(options.setvalue.idx);
                h = view_nii(underlay_nii, options);
            elseif nargin == 1
                h = underlay_nii;
            end
            handle = h;
        end
        
        function underlay_onclick()
            underlay_old = Visual.underlay;
            underlay_new = view_nii(underlay_old.fig);
            if all(underlay_old.viewpoint == underlay_new.viewpoint), return; end
            Visual.underlay(underlay_new);
            overlay_fig = Visual.overlay.fig;
            if ~isempty(overlay_fig)
                options.command = 'update';
                options.setviewpoint = underlay_new.viewpoint;
                view_nii(overlay_fig, options);                
            end
        end
        
        function overlay_onclick()
            overlay_old = Visual.overlay;
            overlay_new = view_nii(overlay_old.fig);
            if all(overlay_old.viewpoint == overlay_new.viewpoint), return; end
            Visual.overlay(overlay_new);
            underlay_fig = Visual.underlay.fig;
            if ~isempty(underlay_fig)
                options.command = 'update';
                options.setviewpoint = overlay_new.viewpoint;
                view_nii(underlay_fig, options);
            end
        end
    end
end

