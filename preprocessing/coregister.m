function job = coregister(t1_path, t2_path)
    temp.ref    = {[t1_path, ',1']};
    temp.source = {[t2_path, ',1']};
    temp.eoptions.cost_fun = 'nmi';
    temp.eoptions.sep = [4 2];
    temp.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    temp.eoptions.fwhm = [7 7];
    temp.roptions.interp = 4;
    temp.roptions.wrap = [0 0 0];
    temp.roptions.mask = 0;
    temp.roptions.prefix = 'r';
    job.spm.spatial.coreg.estwrite = temp;
    spm_jobman('run', {job})
end