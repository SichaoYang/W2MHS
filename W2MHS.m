function W2MHS(varargin)
    if  isdeployed
        if ispc
            [~, result] = system('path');
            w2mhstoolbox_path = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
        elseif nargin == 1
            w2mhstoolbox_path = varargin{1};        
        else
            error('Usage: W2MHS <w2mhstoolbox_path>');
        end
    else
        w2mhstoolbox_path = fileparts(mfilename('fullpath'));
    end
    addpath(genpath(w2mhstoolbox_path));
    WhyD_GUI({w2mhstoolbox_path});
end