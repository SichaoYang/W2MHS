%% script for running docker containers from matlab
function docker_run(command, training_path)
    if ispc, docker = 'docker';
    else, docker = fullfile(training_path, 'docker');
    end
    if system(sprintf('%s run -ti --rm -v %s:/training sichao/w2mhs:v2018.2 %s', docker, training_path, command)) ~= 0
        error('Docker cannot run sichao/w2mhs:v2018.2.');
    end
end