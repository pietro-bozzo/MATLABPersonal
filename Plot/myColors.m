function colors = myColors(i,palette,steps)
% myColors Get a color drawn from personalized palettes
%
% arguments:
%     i          (:,1) double, indices of colors in the palette
%     palette    string = 'default', color palette, can be 'deault', 'IBMcb', or 'rainbow'; rainbow supports:
%                  - is between 0 and 1, interpreted as hue, 0: red, 1: purple
%                  - is positive integers, indeces in rainbow scale, 1: red, steps: purple
%     steps      double = 8, number of rainbow colors in rainbow palette when is are indeces
%
% output:
%     colors     (n_i,3) RGB color arrays between 0 and 1

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  i (:,1) double {mustBeNonnegative}
  palette (1,1) string = 'IBMcb'
  steps (1,1) double {mustBeInteger,mustBePositive} = 8
end

% validate argument
if palette ~= "rainbow" && (any(i==0) || any(mod(i,1)~=0)), error('myColors:iValue','Indices must be positive integers'); end

if palette == "base"
  % use default colors: ["#007efbff"; "#ef8d00ff"; "#75c600ff"; "#d15dffff"; "#ff5656ff"] ADD SOME COLORS
  colors = [0,126,251;
            239,141,0;
            117,198,0;
            209,93,255;
            255,86,86] / 255;
elseif palette == "IBMcb"
  % use IBM's palette suitable for color-blindness colors: ["#648FFF"; "#FE6100"; "#DC267F"; "#FFB000"; "#785EF0"]
  colors = [100,143,255;
            254,97,0;
            220,38,127;
            255,176,0;
            120,94,240
            ] / 255;
elseif palette == "rainbow"
  % use hsv system to produce rainbow gradient
  if any(i>1) % if i corresponds to indeces
    % validate argument
    if any(mod(i,1)~=0), error('myColors:iValue','Indices must be between 0 and 1 or positive integers'); end
    % create rainbow scale
    hue = (0 : steps-1).' / steps;
  else % if i corresponds to hues
    hue = i * 0.8; % make 1 be purple (otherwise 0 = 1 = red)
    i = 1 : numel(i); % set i with intended indeces
  end

  saturation = 0.7;
  value = 0.95;
  colors = hsv2rgb([hue,repmat(saturation,size(hue)),repmat(value,size(hue))]);
  
else
  error('mycolors:unknownPalette','Unknown palette')
end

% make colors circular
i = mod(i-1,size(colors,1)) + 1;
colors = colors(i,:);