function [sorted_perc,labels] = sortNLabelAvals(groups,perc,perc_threshold,member_threshold,regs)
% sortNLabelAvals

% keep groups with representation percentage higher than perc_threshold and number of members higherthan member_threshold
valid_group_ind = perc > perc_threshold & sum(groups,2) > member_threshold;
valid_groups = groups(valid_group_ind,:);
[sorted_perc,sort_ind] = sort(perc(valid_group_ind),'descend');
labels = string.empty;
for i = 1 : size(valid_groups,1)
  disp(regs(valid_groups(sort_ind(i),:)))
  labels = [labels,strjoin(regionID2Acr(regs(valid_groups(sort_ind(i),:))),', ')];
end