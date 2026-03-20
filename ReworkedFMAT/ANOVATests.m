function [p,h,values,errors] = ANOVATests(x,groups,opt)

%ANOVATests - Conduct analysis of variance and multiple-comparisons test
%
%   Test the significance of differences in two-factor data.
%
%  USAGE
%
%    [p,h] = ANOVATests(x,groups,<options>)
%
%    x              data to test, a matrix where each column is a condition
%                   and each row belongs to a group, indicated by 'group'
%    group          grouping variable for rows of 'x', if empty (default),
%                   all rows belong to group 1 (note: group 0 is not allowed);
%                   can be string "group", indicating that groups are in last
%                   column of 'x'
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%    'alpha'        confidence levels for the following tests: (1) between data
%                   and 0, and (2) between pairs of conditions in the same
%                   group (default = [0.05 0.05]); set alpha(i) to zero to 
%                   skip respective test (e.g., alpha = [0 0.05] would skip
%                   tests between each column and zero)
%    'parametric'   either 'on' (default) to compute means and perform t-tests
%                   or 'off' to compute median and perform non-parametric tests
%    'test0'        statistical test for (1), function handle with signature:
%                     p = test0(data_vector,'tail',tail), returning p value
%                   default is ttest / signrank when parametric is 'on' / 'off'
%    'test'         statistical test for (2), function handle with signature:
%                     p = test(x_vector,y_vector), returning p value
%                   defaults:          parametric       paired
%                     anova2              'on'           'on'
%                     anova1              'on'           'off'
%                     friedman            'off'          'on'
%                     kruskalwallis       'off'          'off'
%    'tail'         tail for (1), either 'left', 'right', or 'both' (default)
%    'correction'   type of statistical correction used to control for
%                   multiple comparisons in (2) (default = 'tukey-kramer' or
%                   'bonferroni' when 'test' is provided)
%    'precedence'   if = 2, reverse roles of groups and conditions, i.e., all
%                   pairs of conditions in the same group are tested against each
%                   other (default = 1, except for column vector input)                
%    'paired'       if true, values in the same row are assumed to be paired (and NaNs
%                   are not allowed, default = true, except for column vector input)
%    =========================================================================
%
%  OUTPUT
%
%    handles        a structure of handles for the objects in the figure.
%                   Includes the fields 'bar','errorbars','stars' (for the 
%                   stars above each bar indicating that values in that group
%                   are significantly different from 0), and 'comparisons'
%                   for all the objects (lines and stars) illustrating the 
%                   between-group comparisons.
%    h              h > 0 if the null hypothesis (that the groups are not 
%                   different) can be rejected (h values of 1, 2, and 3, 
%                   correspond to confidence levels 0.05, 0.01, and 0.001, 
%                   respectively)
%
%   Provide data as a matrix (each column will be treated separately), or
%   as grouped data with "group" as a grouping vector (each line indicating
%   which group the respective row in "data" corresponds to). Alternatively,
%   the grouping vector could be the last column of 'data' itself, in which case
%   you can call anovabar(data,'grouped');
%
%  EXAMPLES
%
%  Case 1: the two columns of 'data' correspond to two paired conditions
%  (e.g. control firing 2s before the intervals of interest and
%  the response of interest). Each row corresponds to paired observations:
%       data = [CountInIntervals(spikes(:,1),intervals-2) CountInIntervals(spikes(:,1),intervals)];
%       anovabar(data); % or anovabar(data,[]);
%  Note that for parametric data, the anova will not take the pairing into 
%  account (but for non-parametric data, a paired friedman test is performed).
%
%  Case 2: the observations are not paired; groups are therefore indicated
%  separately by a grouping variable:
%       controlData = CountInIntervals(spikes(:,1),baseline);
%       % note that here, 'baseline' intervals are not necessarily paired to the intervals of interest below
%       responseData = CountInIntervals(spikes(:,1),intervals);
%       data = [controlData; responseData]; groups = [ones(size(controlData)); ones(size(responseData))*2];
%       anovabar(data,groups);
%
%  Case 2bis: same as Case 2, but the grouping variable is contained within 'data':
%       controlData = CountInIntervals(spikes(:,1),baseline); controlData(:,end+1) = 1;
%       responseData = CountInIntervals(spikes(:,1),intervals); responseData(:,end+1) = 2;
%       data = [controlData; responseData];
%       anovabar(data,'grouped'); % or, of course, anovabar(data(:,1),data(:,end)) as in case 2
%
%  Case 3: two-way anova: data are grouped according to the columns in 'data'
%       AND ALSO by the grouping variable. In this case, the difference between the
%       (paired) columns will be tested for each of the groups indicated by the grouping
%       variable. For the opposite behavior (testing for the difference between the
%       (unpaired) groups indicated by the grouping variable, for each of the columns
%       of 'data', use <a href="matlab:help anovabar2">anovabar2</a>.

% Copyright (C) 2018-2022 by Ralitsa Todorova & (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

arguments
    x (:,:) {mustBeNumeric}
    groups (:,1) = []
    opt.alpha (1,:) {mustBeNumeric,mustBeNonnegative} = [0.05,0.05]
    opt.parametric (1,1) {mustBeLogical} = true
    opt.test0 (1,1) = "default"
    opt.test (1,1) = "default"
    opt.tail (1,1) string {mustBeMember(opt.tail,["both","right","left"])} = "both"
    opt.correction (1,1) string = "tukey-kramer"
    opt.precedence {mustBeIn(opt.precedence,{1,2,[]})} = []
    opt.paired {mustBeLogicalScalarOrEmpty} = []
end

% validate arguments
if isnumeric(groups) && ~isempty(groups) && numel(groups) ~= size(x,1)
    error('anovaTest:groupsSize','Argument ''groups'' must have one element per row of ''x'' (type ''help <a href="matlab:help ANOVATests">ANOVATests</a>'' for details).')
elseif ~isnumeric(groups) && ~isastring(groups,'groups','grouped','group')
    error('anovaTest:groupsValue','Argument ''groups'' must be numeric or "group" (type ''help <a href="matlab:help ANOVATests">ANOVATests</a>'' for details).')
end
if isempty(opt.alpha) || numel(opt.alpha) > 2
    error('anovaTest:alphaSize','Property ''alpha'' must have one or two elements (type ''help <a href="matlab:help ANOVATests">ANOVATests</a>'' for details).');
end

% default values
if isscalar(opt.alpha)
    opt.alpha = [opt.alpha,opt.alpha];
end
if opt.parametric
    average = @(x) mean(x,1,'omitnan');
    semfun = @(x) nansem(x,1);
else
    average = @(x) median(x,1,'omitnan');
    semfun = @(x) semedian(x,1);
end
if isempty(groups)
    groups = ones(size(x,1),1);
elseif isastring(groups,'groups','grouped','group')
    groups = x(:,end);
    x = x(:,1:end-1);
end
if isempty(opt.precedence)
  opt.precedence = 1 + double(size(x,2) == 1);
end
if isempty(opt.paired)
  opt.paired = size(x,2) ~= 1;
end

% remove rows belonging to no group
x = x(~isnan(groups),:);
groups = groups(~isnan(groups));
unique_groups = unique(groups);
nGroups = numel(unique_groups);
nCols = size(x,2);

if opt.precedence == 2
    % reverse groups and conditions (row labels and columns)
    n_per_group = accumarray(groups,1); % number of rows of x per group
    if opt.paired && any(n_per_group ~= n_per_group(1))
        error('ANOVATest:reversePairedInput','Number of elements in every group must be equal to conduct a paired test with precedence 2.')
    end
    max_npg = max(n_per_group);
    new_x = nan(nCols*max_npg,nGroups);
    for j = 1 : nCols
        for i = 1 : nGroups
            this_column_data = x(groups==unique_groups(i),j);
            new_x((j-1)*max_npg + (1:numel(this_column_data)),i) = this_column_data;
        end
    end
    nGroups = size(x,2);
    unique_groups = (1 : nGroups).';
    groups = repelem(unique_groups,max_npg,1);
    x = new_x;
    nCols = size(x,2);
end

% set up tests
if ~isastring(opt.test0)
    test0 = @(x) opt.test0(x,[],'tail',opt.tail);
elseif opt.parametric
    test0 = @(x) out2(@ttest,x,[],'tail',opt.tail); % COULD MAKE GENERAL outN function
else
    test0 = @(x) signrank(x,[],'tail',opt.tail);
end
if ~isastring(opt.test)
    testbetween = @(x) pairwiseTest(@opt.test,x);
elseif opt.parametric
    if opt.paired
        testbetween = @(x) anova2(x,1,'off');
        opt.test = "anova2";
    else
        testbetween = @(x,g) anova1(x,[],'off');
        opt.test = "anova1";
    end
else
    if opt.paired
        if size(x,2) == 2
            testbetween = @(x) pairwiseTest(@signrank,x);
            opt.test = "signrank";
        else
            testbetween = @(x) friedman(x,1,'off'); 
            opt.test = "friedman";
        end
    else
        testbetween = @(x) kruskalwallis(x,[],'off');
        opt.test = "kruskalwallis";
    end
end

% validate absence of single NaNs when paired input
if opt.paired
    nan_row = all(isnan(x),2);
    x = x(~nan_row,:);
    groups = groups(~nan_row);
    if any(isnan(x),'all')
        error('ANOVATest:pairedInput','NaNs are not allowed in a paired test.')
    end
end

% compute averages
values = nan(nGroups,nCols);
errors = nan(nGroups,nCols);
for i = 1 : nGroups
    values(i,:) = average(x(groups==unique_groups(i),:));
    errors(i,:) = semfun(x(groups==unique_groups(i),:));
end

% 1. test if each group differs from zero
if opt.alpha(1) > 0
    p.p0 = nan(nGroups,nCols);
    for j = 1 : nCols
        p.p0(:,j) = accumarray(groups,x(:,j),[],test0);
    end
    h.h0 = holmBonferroni(p.p0,opt.alpha(1));
end

% 2. ANOVA and multiple comparisons WHEN THERE'S ONLY 1 COL, multcompare ERRORS
if opt.alpha(2) > 0
    for i = 1 : nGroups
        [~,~,stats] = testbetween(x(groups==unique_groups(i),:));
        labels = ["p","h"] + string(unique_groups(i));
        [p.(labels(1)),h.(labels(2))] = multipleComparisons(stats,opt.alpha(2),opt.correction,opt.test);
    end
end

end

% ------------------------------- Helper functions -------------------------------

function [dummya,dummyb,p] = pairwiseTest(test,data)
    % conduct test on all pairs of columns of data, test has signature
    % p = test(x,y)
    dummya = []; dummyb = []; % dummy outputs
    inds = nchoosek(1:size(data,2),2);
    p = [inds,nan(size(inds,1),1)];
    for i = 1 : size(inds,1)
        p(i,3) = test(data(:,inds(i,1)),data(:,inds(i,2)));
    end
end

function [p,h] = multipleComparisons(stats,alpha,correction,test)
    % multiple comparisons test
    if isstring(test) && ismember(test,["anova1","anova2","anovan","aoctool","friedman","kruskalwallis"])
        % stats is output of one of listed functions, accepted by multcompare
        comparison = multcompare(stats,'display', 'off','alpha',alpha,'ctype',correction); % *, default alpha = 0.05
        p = comparison(:,[1,2,end]);
        comparison = [comparison(:,1:2),comparison(:,3).*comparison(:,5)>0]; % if the upper and lower bound have the same sign
        comparison2 = multcompare(stats,'display', 'off', 'alpha', alpha/5,'ctype',correction); % **, default alpha = 0.01
        comparison(:,3) = comparison(:,3) + double(comparison2(:,3).*comparison2(:,5)>0); % third column shows the number of stars to be included. 1 for 0.05, 1 more for 0.01, and another one for 0.001       if sum(double(comparison2(:,3).*comparison2(:,5)>0)),
        comparison3 = multcompare(stats,'display', 'off', 'alpha', alpha/50,'ctype',correction); % ***, default alpha = 0.001
        comparison(:,3) = comparison(:,3) + double(comparison3(:,3).*comparison3(:,5)>0);
        h = comparison;
    else
        % for other pair-wise tests, multcompare will not work, stats is assumed to list p values for every possible pair of groups
        % Holm-Bonferroni correction is automatically applied
        p = stats; h = stats;
        h(:,3) = holmBonferroni(p(:,3)); % alpha IS IGNORED HERE NOW
        % h = 1: * (default alpha = 0.05), h = 2: ** (default alpha = 0.01), h = 3: *** (default alpha = 0.001)
        h(h(:,3)==1,3) = (p(h(:,3)==1,3) < alpha) + (p(h(:,3)==1,3) < alpha/5) + (p(h(:,3)==1,3) < alpha/50);
    end
end