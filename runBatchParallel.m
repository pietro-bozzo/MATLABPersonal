function varargout = runBatchParallel(batch_file,func,args,opt)
% runBatch Run in parallel a routine on multiple sessions
%
% arguments:
%     batch_file    char, file path to text file, where each line must be the path to a session's xml file; comments are allowed (see usage)
%     func          function handle, func must accept a line of batch_file as its first argument and is called once for each line
%     args          (n_args,1) cell, optional additional arguments passed to func; passing different argument values for different
%                   sessions is not supported
%
% name-value arguments:
%     ignore_args   logical = false, if true, ignore optional arguments written in 'batch_file'
%     verbose       logical = false, if true, log batch progress to console
%
% output:
%     varargout     (1,n_out_func) of (n_sessions,1) cell, i-th element of varargout is a cell array containing all i-th outputs of func for
%                   every session; outputs of func can be caught separately when calling runBatch (see usage)
%
% usage:
%
%     let batch file, named 'my_batch.txt', contain:
%         path/to/session1.xml
%         path/to/session2.xml % comment
%         % path/to/session3.xml this session is commented and will be ignored
%         path/to/session4.xml %comment
%
%     function myFunction has signature:
%         [a,b] = myFunction(session,c,d)
%
%     runBatchParallel can be used as follows:
%         args = {c_value,d_value};
%         [a_result,b_result] = runBatchParallel('my_batch.txt',@myFunction,args,verbose=true);
%
%     Name-Value arguments of func can be passed as:
%         args = {arg1,arg2,'NameValueArg1',Value1,'NameValueArg2',Value2};

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

% TO IMPLEMENT:  error log saved in workspace, indeces of ok sessions

arguments
    batch_file (1,:) char
    func (1,1) function_handle
    args (:,1) cell = {}
    opt.ignore_args {mustBeLogical} = false
    opt.sessions = []
    opt.verbose (1,1) logical = false
end

% create variable not to broadcast structure opt to parfor workers
verbose = opt.verbose;
ignore_args = opt.ignore_args;

% parse batch file
[sessions,extra_args] = readBatchFile(batch_file);
if ~isempty(opt.sessions)
  sessions = sessions(opt.sessions);
  extra_args = extra_args(opt.sessions);
end

% run routine
verbose && fprintf(1,"\nStarting parallel Batch, "+string(datetime)+" \n");
n_outs = nargout(func);
n_sessions = numel(sessions);
% set up batch output
batch_output = cell(n_sessions,n_outs);
errors = false(n_sessions,1);
parfor i = 1 : numel(sessions)
  output = cell(n_outs,1);
  try
    if ignore_args
      [output{:}] = func(sessions(i),args{:});
    else
      [output{:}] = func(sessions(i),args{:},extra_args{i}{:});
    end
  catch except
    errors(i) = true;
    % SAVE error stack SOMEWHERE
    %fprintf(2,'Error in session %s\n',sessions(i))
    %fprintf(2,'%s\nStacktrace:\n\n',except.message)
    %for j = 1 : length(except.stack)
      %fprintf(2,'Error in %s (line %d)\n',except.stack(j).name,except.stack(j).line)
    %end
    %fprintf(2,'\n')
  end
  % assign session outputs, empty if an error occurred
  for j = 1 : n_outs
    batch_output{i,j} = output{j};
  end
end

% log progress to console
verbose && fprintf(1,'Batch completed with %d errors',sum(errors));
if any(errors) && verbose
  fprintf(1,' in sessions: \n');
  for i = find(errors).'
    fprintf(2,sessions(i)+'\n');
  end
  fprintf(1,'Use runBatch for a complete error stack');
end
verbose && fprintf(1,'\n');

% distribute outputs to varargout
varargout = cell(1,n_outs);
for j = 1 : n_outs
  varargout{j} = batch_output(:,j);
end