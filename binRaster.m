function binned_raster = binRaster(raster,bin_size)
% binRaster Bin time axis of a raster of activity
% Requires ndSparse toolbox for compatibility with sparse matrices
%
% arguments:
% raster (:,:) {mustBeLogical}                                    raster of units activity
% bin_size (1,1) double {mustBeGreaterThanOrEqual(bin_size,1)}    number of time steps of raster for a bin

arguments
    raster (:,:)
    bin_size (1,1) double {mustBeGreaterThanOrEqual(bin_size,1)}
end

if isempty(raster)
    binned_raster = raster;
else
    if issparse(raster)
        % preserve sparsity
        binned_raster = ndSparse.build([],[],[size(raster,1),ceil((size(raster,2))/bin_size),ceil(bin_size)]);
    else
        binned_raster = zeros(size(raster,1),ceil((size(raster,2))/bin_size),ceil(bin_size));
    end
    bin_indeces = [1,ceil((1:size(raster,2)-1)/bin_size)];
    ind = [0,bin_indeces(2:end)==bin_indeces(1:end-1)] + 1;
    for i = 1 : ceil(bin_size) - 2
        ind = ind + [0,ind(2:end)==ind(1:end-1)];
    end
    linear_ind = sub2ind([size(binned_raster,2),size(binned_raster,3)],bin_indeces,ind);
    binned_raster(:,linear_ind) = raster;
    binned_raster = sum(binned_raster,3);
    % IF IT WAS LOGICAL, RESTORE That binr = binr > 0
    if issparse(raster)
        % restore classic sparse object
        binned_raster = sparse(binned_raster);
    end
end