function output = runBatch(batch_file,func,args,opt)
% runBatch Run given routine on multiple sessions
%

% IMPLEMENT: error log saved in workspace, varargout with one cell array per f output + indeces of ok sessions

arguments
    batch_file (1,:) char
    func (1,1) function_handle
    args (:,1) cell = {}
    opt.verbose (1,1) logical = false
end

% parse batch file
fileID = fopen(batch_file);
if fileID == -1
  error(append('Unable to open ',batch_file));
end
lines = textscan(fileID,'%s',CommentStyle='%',Delimiter='\n');
sessions = strings().empty();
for line = lines{1}'
  if ~isempty(line{1})
    % OCCORREREBBE strsplit con % per beccare commnenti del tipo aa%bb
    words = textscan(line{1},'%s',CommentStyle='%');
    sessions(end+1,1) = words{1}{1};
    for i = 2 : numel(words)
      words{i}; % WORDS MIGHT BE USELESS NOW
    end
  end
end

% run routine
output = cell(numel(sessions),1);
errors = 0;
for i = 1 : numel(sessions)
  if opt.verbose
    fprintf(1,append('Batch progress: ',string(i),' out of ',string(numel(sessions)),'\n'))
  end
  try
    output{i} = cell(nargout(func),1);
    [output{i}{:}] = func(sessions(i),args{:});
  catch except
    errors = errors + 1;
    fprintf(2,'Error in session %s\n',sessions(i))
    fprintf(2,'%s\nStacktrace:\n\n',except.message)
    for j = 1 : length(except.stack)
      fprintf(2,'Error in %s (line %d)\n',except.stack(j).name,except.stack(j).line)
    end
    fprintf(2,'\n')
  end
  if opt.verbose
    fprintf(1,'\n')
  end
end
if opt.verbose
  fprintf(1,'Batch completed with %d errors.\n',errors)
end