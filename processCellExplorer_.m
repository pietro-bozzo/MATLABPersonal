function processCellExplorer_(session,labels,groups)

arguments
  session (1,:) char
  labels (:,1) string
  groups (:,1) cell
end

if numel(labels) ~= numel(groups)
  error('processCellExplorer_:groupsSize','Arguments ''labels'' and ''groups'' must have the same number of elements')
end

[basepath,basename] = fileparts(session);


% --- code for Marco's data ---
rat = str2double(basename(4:6));
anat_file = '/mnt/hubel-data-103/Pietro/Code/MATLAB/Regions/Data/bilateral.anat';
legend = cellfun(@(y) y{1},cellfun(@(x) strsplit(x,'%'),readlines(anat_file),'UniformOutput',false),'UniformOutput',false);
legend = legend(~cellfun(@isempty,legend));
legend = cellfun(@(x) textscan(x,'%f,%f,%s'),legend,'UniformOutput',false);
legend_rat = cellfun(@(x) x{1},legend);
legend_electrode = cellfun(@(x) x{2},legend);
legend_label = string(cellfun(@(x) x{3},legend));
labels = legend_label(legend_rat==rat);
groups = legend_electrode(legend_rat==rat);
[ulabels,~,uind] = unique(labels);
for i = 1 : numel(ulabels)
  ugroups{i} = groups(uind==i).';
end
labels = ulabels;
groups = ugroups;
% --- end ---


animalName = basename(1:6);
session = sessionTemplate(basepath,'showGUI',false,'basename',basename);
session.animal.name = animalName;
session.animal.species = 'Rat';
for i = 1 : numel(labels)
  session.brainRegions.(labels(i)) = groups{i};
end
save(fullfile(basepath,[basename '.session.mat']),'session');
spikes = loadSpikes('format','Klustakwik','saveMat',true,'basepath',basepath,'basename',basename);
cell_metrics = ProcessCellMetrics('spikes',spikes,'session',session,'sessionSummaryFigure',false,'manualAdjustMonoSyn',false);

end

% removed /media/data-103/Pascale/MatlabPath/1_Matlab_Codes/core/ from path ('range' clash)