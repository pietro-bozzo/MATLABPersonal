function percentile = percentRank(x,p,dir)
% get corresponding percentiles (in [0,1]) of values p in data x

arguments
  x (:,:) % n_observation, n_data_sets
  p (:,:) % n_values, n_data_sets
  dir (1,1) string {mustBeMember(dir,["up","down","center"])} = "up"
end

if size(x,2) ~= size(p,2)
  error('percentRank:inputSize','''x'' and ''p'' must have the same number of columns')
end

percentile = zeros(size(p));
for i = 1 : size(x,2)
  percentile(:,i) = mean(x(:,i).' <= p(:,i),2);
end

if dir == "down"
  percentile = 1 - percentile;
elseif dir == "center"
  percentile = 2 * percentile;
  percentile(percentile>1) = 2 - percentile(percentile>1);
end