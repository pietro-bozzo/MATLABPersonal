function rat = getRatNumber()
% getRatNumber Get rat number of current session

ratNumber = @(x) str2double(x((3:5)+min(strfind(lower(x),'rat'))));
rat = ratNumber(GetCurrentSession().basename);