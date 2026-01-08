function shuffled_raster = shuffleSpikeMatrix(raster)
% shuffleSpikes Shuffle spike raster preserving inter-spike intervals distribution for each unit

arguments
  raster (:,:) double    % rasterij = 1 iff unit i spikes in time bin j
end

shuffled_raster = zeros(size(raster));
%time_stamps = find(raster);
%time_stamps = time_stamps(:,1);
for i = 1 : size(raster,1)
  time_stamps = find(raster(i,:)).';  % MOVE OUT OF FOR
  if ~ isempty(time_stamps)
    inter_spike_intervals = time_stamps(2:end) - time_stamps(1:end-1); % MOVE OUT OF FOR
    % shuffle inter-spike intervals
    inter_spike_intervals = [time_stamps(1);inter_spike_intervals(randperm(numel(inter_spike_intervals)))];
    shuffled_raster(i,cumsum(inter_spike_intervals)) = 1; % MOVE OUT OF FOR
  end
end