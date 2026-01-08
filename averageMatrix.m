function [result,result2] = averageMatrix(matrix,r_indeces,c_indeces,opt)
% plotATMs Average each submatrix of the input matrix, following provided indeces

arguments
  matrix (:,:) double
  r_indeces (:,1) double {mustBeNonnegative}
  c_indeces (:,1) double {mustBeNonnegative} = r_indeces
  opt.percentile (1,1) double {mustBePositive,mustBeLessThanOrEqual(opt.percentile,1)} = 0.25; % fraction of values to average
  opt.ignore_nans (1,1) {mustBeLogical} = true; % if false, count number of NaNs in average
  opt.matrix2 (:,:) double = [] % second matrix on which to operate the same average as for matrix
end

if sum(r_indeces) ~= size(matrix,1) || sum(c_indeces) ~= size(matrix,2)
  error('averageMatrix:WrongIndeces','Specified indeces must cover all rows and columns of matrix.')
end
if ~isempty(opt.matrix2) && any(size(matrix)~=size(opt.matrix2))
  error('mustHaveDims:WrongDim','Invalid value for ''matrix2'' argument. Value must be have the same size of first argument.')
end
if any(r_indeces == 0) || any(c_indeces == 0)
  warning('An empty submatrix was requested.')
end

result = NaN(numel(r_indeces),numel(c_indeces)); % NaN for empty elements in result, when r_indeces or c_indeces have zero identical elements
if isempty(opt.matrix2)
  result2 = [];
else
  result2 = NaN(numel(r_indeces),numel(c_indeces));
end
r_indeces = [0;cumsum(r_indeces)]; % to correctly index submatrices
c_indeces = [0;cumsum(c_indeces)];
for i = 1 : numel(r_indeces) - 1
  for j = 1 : numel(c_indeces) - 1
    if r_indeces(i) ~= r_indeces(i+1) && c_indeces(i) ~= c_indeces(i+1)
      % get values to average
      submatrix = matrix(r_indeces(i)+1:r_indeces(i+1),c_indeces(j)+1:c_indeces(j+1));
      values = abs(reshape(submatrix,[],1)); % flatten and take absolute value to average extremes in both directions
      valid_ind = ~isnan(values);
      values(~valid_ind) = -1; % set NaNs as negative to ignore their value
      [~,ind] = sort(values,'descend'); % get indeces of highest absolute value elements
      ind = ind(1:sum(valid_ind)); % keep only indeces of non-NaN elements
      % average requested fraction of values
      if opt.ignore_nans
        normalize = sum(valid_ind); % account only for non-NaNs
      else
        normalize = numel(values); % account also for number of NaNs
      end
      result(i,j) = sum(submatrix(ind(1:round(opt.percentile*numel(ind))))) / normalize;
      if ~isempty(opt.matrix2)
        % repeat average on second matrix
        submatrix = opt.matrix2(r_indeces(i)+1:r_indeces(i+1),c_indeces(j)+1:c_indeces(j+1));
        if opt.ignore_nans
          normalize = sum(~isnan(submatrix));
        else
          normalize = numel(submatrix);
        end
        result2(i,j) = sum(submatrix(ind(1:round(opt.percentile*numel(ind))))) / normalize;
      end
    end
  end
end