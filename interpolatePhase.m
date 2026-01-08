function phase = interpolatePhase(resolution,times,values,opt)
% interpolatePhase Get linearly-interpolated istantaneous phase from phase samples (e.g., from peaks and troughs)
%
% arguments:
%     resolution    double, output sampling resolution in seconds
%     times         repeating (n,1) double, time stamps for a given phase value
%     values        repeating (1,1) double, phase value for corresponding time stamps in a vector of 'times'
%
% name-value arguments:
%     range         (1,2) double = [0,2*pi], [a,b] interval defining a full rotation, with b > a
%     wrap          logical = true, if true, return phases in [a,b] (modulo b-a); time stamps for b and a are added without respecting resolution
%
% output:
%     phase         (m,2) double, columns are: times, interpolated phases
%
% usage:
%     % get linear phase specifying times when it is 0 and times when it is pi
%     phase = interpolatePhase(0.01,[1,5.5,8],0,[2,6,9],pi);
%
%     % different numbers of time stamps can be given for different phase values
%     phase = interpolatePhase(0.01,[1,4,8],0,[2,5,9,10],pi);

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
  
arguments
  resolution (1,1) {mustBeNumeric,mustBePositive}
end
arguments (Repeating)
  times (:,1) {mustBeNumeric}
  values (1,1) {mustBeNumeric}
end
arguments
  opt.range (1,2) {mustBeNumeric} = [0,2*pi]
  opt.wrap (1,1) {mustBeLogical} = true
end

if diff(opt.range) <= 0
  error('interpolatePhase:rangeValue','Argument ''range'' must be increasing')
end
a = opt.range(1); b = opt.range(2);
if numel(times) ~= numel(values)
  error('interpolatePhase:inputNumber','Number of ''times'' and ''values'' must be equal')
end
if any(cellfun(@(x) x < a || x > b,values))
  error('interpolatePhase:valuesRange',"Argument ''values'' must take values inside ''range'': ["+strjoin(string(opt.range),',')+"]")
end
 
% unwrap values
n_elements = cellfun(@numel,times);
values = repelem(vertcat(values{:}),n_elements,1);
phase = sortrows([vertcat(times{:}),values]);
is_new_cycle = [false;phase(1:end-1,2) >= phase(2:end,2)];
phase(:,2) = phase(:,2) + (b-a)*cumsum(is_new_cycle);

% interpolate
interp_times = (0 : resolution : phase(end,1)+resolution).';
interp_phase = interp1(phase(:,1),phase(:,2),interp_times);
interp_times = interp_times(~isnan(interp_phase)); % remove values outside domain
interp_phase = interp_phase(~isnan(interp_phase));

if opt.wrap

  % find where new cycles begin
  new_cycle_phases = (b : (b-a) : interp_phase(end)).';
  new_cycle_times = interp1(interp_phase,interp_times,new_cycle_phases);
  new_cycle_ind = discretize(new_cycle_phases,interp_phase) + 1;

  % build final phases
  phase = zeros(numel(interp_times)+2*numel(new_cycle_ind),2);

  % find indeces of gaps to add
  gap_ind = new_cycle_ind + (2*(0 : numel(new_cycle_ind)-1)).';
  is_non_gap = true(size(phase,1),1);
  is_non_gap(gap_ind) = false;
  is_non_gap(gap_ind+1) = false;

  % assign previous values
  phase(is_non_gap,:) = [interp_times,modulo(interp_phase,a,b)];
  % assign cycle-breaking values
  phase(gap_ind,:) = [new_cycle_times,b*ones(size(new_cycle_times))];
  phase(gap_ind+1,:) = [new_cycle_times+resolution/100,a*ones(size(new_cycle_times))];
  % remove repeated time samples (present when interpolated phase equals a multiple of b-a)
  [~,ind] = unique(phase(:,1),'stable');
  phase = phase(ind,:);
  phase = phase(diff(phase(:,1))>0,:);

else

  phase = [interp_times,interp_phase];

end

end

% --- helper functions ---

function m = modulo(x,a,b)
% modulo Remap all elements of x to numbers in [a,b], using modulo b-a transformations; b > a is expected

  m = mod(x,b-a);
  m(m<a) = m(m<a) + b - a;
  m(m>b) = m(m>b) - b + a;

end