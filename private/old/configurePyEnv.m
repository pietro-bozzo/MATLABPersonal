function configurePyEnv(machine,options)
%configurePyEnv Configure Python environment to run powerlaw_analysis.py
%
% arguments:
% machine (1,1) string             machine on which the script is running
% verbose (1,1) logical = false    if true, print comments

arguments
    machine (1,1) string
    options.verbose (1,1) logical = false
end

% function configurePyEnv(machine)
if strcmp(machine,'hubel')
    pyenv(Version='/home/programs/python/anaconda3/envs/powerlaw/bin/python3.8',ExecutionMode='OutOfProcess');
elseif strcmp(machine,'galvani')
    pyenv(Version='/home/conda/anaconda3/envs/powerlaw/bin/python3',ExecutionMode='OutOfProcess');
elseif options.verbose
    fprintf(1,'Unrecognized machine, setting default options (powerlaw python environment is required)')
end