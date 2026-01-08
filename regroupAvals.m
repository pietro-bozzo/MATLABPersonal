function new_group_ind = regroupAvals(groups,new_groups,group_ind)
% regroupAvals Regroup avalanches by fusing original groups

arguments
  groups (:,:) {mustBeLogical} % exclusive groups
  new_groups (:,:) {mustBeLogical} % each row is a regrouping rule
  group_ind (:,1) double {mustBeInteger,mustBePositive} % exclusive-group index for each avalanche
end

% validate inputs
if size(groups,2) ~= size(new_groups,2)
  error('regroupAvals:groupSize','Groups and new groups must have the same number of columns')
end
groups = logical(groups);
new_groups = logical(new_groups);

new_group_ind = false(numel(group_ind),size(new_groups,1));

for i = 1 : size(new_groups,1)
  new_group_ind(:,i) = any(groups(group_ind,new_groups(i,:)),2);
end


% regroups = zeros(size(groups,1),numel(new_groups));
% 
% 
% for i = 1 : numel(new_groups)
%   regroups(:,i) = any(groups(:,new_groups(i)),2);
% end
% [regroups,ia,ic] = unique(regroups,'rows');
% regorup_ind = ic(group_ind);
% 
% 
% % keep groups with representation percentage higher than perc_threshold and number of members higherthan member_threshold
% valid_group_ind = perc > perc_threshold & sum(groups,2) > member_threshold;
% valid_groups = groups(valid_group_ind,:);
% [sorted_perc,sort_ind] = sort(perc(valid_group_ind),'descend');
% labels = string.empty;
% for i = 1 : size(valid_groups,1)
%   disp(regs(valid_groups(sort_ind(i),:)))
%   labels = [labels,strjoin(regionID2Acr(regs(valid_groups(sort_ind(i),:))),', ')];
% end