%% Run CellExplorer ProcessCellMetrics routine on multiple sessions

% set up batch
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/karadoc.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/perceval.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/blinky.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/sasuke.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/sakura.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/IS_intervals_dvHPC.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/cell_explorer.batch';

runBatch(batch_file,@processCellExplorer_,'verbose',true,'sessions',1:36);