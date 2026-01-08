function iei = getIEI(raster)
% getIEI Compute average inter-event interval from raster of activity, measured in time bins
% Returns NaN for an empty input
%
% arguments:
% raster (:,:) {mustBeLogical}    raster of units activity

arguments
    raster (:,:) {mustBeLogical}
end

events = sum(raster,1);
nonzero_indeces = find(events);
ieis = nonzero_indeces(2:end) - nonzero_indeces(1:end-1);
iei = mean([ieis,zeros(1,sum(events(events>1)-1))]); % add zeros corresponding to ...