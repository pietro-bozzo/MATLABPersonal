function callPowerlaw(input_file,output_file,opt)
% callPowerlaw Call powerlaw_analysis.py to get criticality metrics
%
% arguments:
% input_file (1,1) string         file path to text file containing data to analyse
% output_file (1,1) string        file path to save results to
% fig_file (1,1) string = ""      file path to save figure to, default saves none
% fig_title (1,1) string = ""     figure title

arguments
    input_file (1,1) string
    output_file (1,1) string
    opt.fig_file (1,1) string = ""
    opt.fig_title (1,1) string = ""
end

line = append(getPietroPath,'/Python/powerlaw_analysis.py ',input_file,' ',output_file);
if ~strcmp(opt.fig_file,"")
    line = append(line,' -f ',opt.fig_file);
    if ~strcmp(opt.fig_title,"")
        line = append(line,' -t ',opt.fig_title);
    end
end
pyrunfile(line);