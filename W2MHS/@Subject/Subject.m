classdef Subject
    properties
        id
        t1_path
        t2_path
        names
        keeps
    end
    
    methods (Static)
        function vget = spm_path(vset), persistent v; if nargin, v = vset; end; vget = v; end
        function vget = output_path(vset), persistent v; if nargin, v = vset; end; vget = v; end
        function vget = do_preproc(vset), persistent v; if nargin, v = strcmpi(vset, 'yes'); end; vget = v; end
        function vget = do_visual(vset), persistent v; if nargin, v = strcmpi(vset, 'yes'); end; vget = v; end
        function vget = batch_size(vset), persistent v; if nargin, v = max(vset, 1); end; vget = v; end
        function vget = pmap_cut(vset), persistent v; if nargin, v = max(min(vset, 1), 0); end; vget = v; end
        function vget = clean_th(vset), persistent v; if nargin, v = max(vset, 0); end; vget = v; end
        function vget = vent_dil_r(vset), persistent v; if nargin, v = max(vset, 0); end; vget = v; end
        function vget = output_table(vset), persistent v; if nargin, v = vset; end; vget = v; end
    end
    
    methods        
        function obj = Subject(id, t1_path, t2_path)
            obj.id = id;
            obj.names.t1_source = t1_path;
            obj.names.t2_source = t2_path;
        end
        
        obj = preproc(obj)
        obj = detect(obj)
        obj = postproc(obj)
        obj = quant(obj)
        
        function obj = run(obj)
            if ~exist(obj.names.folder, 'dir'), mkdir(obj.names.folder); end
            % load and resave the source files to ensure header consistency
            save_nii(load_nii(obj.names.t1_source), obj.ff(obj.names.t1));
            save_nii(load_nii(obj.names.t2_source), obj.ff(obj.names.t2));
            obj.preproc;
            obj.detect;
            obj.postproc;
            if obj.keeps.names, obj.savenames; end
            if obj.do_visual, Visual.init(obj.ff(obj.names.bias_corr), obj.ff(obj.names.pmap), false); end
        end
        
        function abs_path = ff(obj, rel_path)
            abs_path = fullfile(obj.names.folder, rel_path);
        end
        
        function del(obj, name)
            path = obj.ff(obj.names.(name));
            if ~obj.keeps.(name) && exist(path, 'file'), delete(path); end
        end
        
        function savenames(obj)
            fields = fieldnames(obj.names);
            for i = 1:numel(fields)
                if ~isfield(obj.keeps, fields{i}) || obj.keeps.(fields{i})
                    names.(fields{i}) = obj.ff(obj.names.(fields{i}));
                end
            end
            save(obj.ff(obj.names.names), 'names');
        end
    end
end