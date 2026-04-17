function processCellExplorer_(session,labels,groups)

arguments
  session (1,:) char
  labels (:,1) string = [] % REMOVE = []
  groups (:,1) cell = [] % REMOVE = []
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


% animalName = basename(1:6);
% session = sessionTemplate(basepath,'showGUI',false,'basename',basename);
%session.animal.name = animalName;
%session.animal.species = 'Rat';
%for i = 1 : numel(labels)
%  session.brainRegions.(labels(i)) = groups{i};
%end
%save(fullfile(basepath,[basename '.session.mat']),'session');
% spikes = loadSpikes('format','Klustakwik','saveMat',true,'basepath',basepath,'basename',basename);
% cell_metrics = ProcessCellMetrics('spikes',spikes,'session',session,'sessionSummaryFigure',false,'manualAdjustMonoSyn',false);

% assign brain region label to each unit
% changed = false;
% for i = 1 : numel(cell_metrics.brainRegion)
%   if isempty(cell_metrics.brainRegion{i})
%     idx = find(cellfun(@(x) ismember(cell_metrics.electrodeGroup(i),x),groups),1); % WRONG FOR fear cond data
%     cell_metrics.brainRegion{i} = labels(idx);
%     changed = true;
%   end
% end
% if changed
%   saveCellMetrics(cell_metrics,fullfile(basepath,basename+".cell_metrics.cellinfo.mat"))
% end

% correct wrong region assignment
load(fullfile(basepath,basename+".cell_metrics.cellinfo.mat"))
if ~all(cell_metrics.electrodeGroup==cell_metrics.hexatrode)
  disp(basename)
  for i = 1 : numel(cell_metrics.brainRegion)
    idx = find(cellfun(@(x) ismember(cell_metrics.hexatrode(i),x),groups),1);
    cell_metrics.brainRegion{i} = labels(idx);
  end
  saveCellMetrics(cell_metrics,fullfile(basepath,basename+".cell_metrics.cellinfo.mat"))
end