%% Run CellExplorer ProcessCellMetrics routine on multiple sessions

% set up batch
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/karadoc.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/perceval.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/blinky.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/sasuke.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/sakura.batch';
batch_file = '/mnt/hubel-data-103/Pietro/Data/BatchFiles/IS_intervals_dvHPC.batch';

% choose parameter values
labels = ["mPFC","HPC","NR"];
groups = {[3,4],[5,6,7],[1,2]};

args = {labels,groups};
runBatch(batch_file,@processCellExplorer_,args,'ignore_args',true,'verbose',true,'sessions',4:14);