function time_stamps = getEventSleepStamps(session,event)
% getEventStamps Get start and stop time stamps for requested event of a session and surrounding sleep

arguments
  session (1,:) char
  event (1,1) string
end

% load events file
[events,stamps] = loadEvents(session);
% get first task name if required
if event == "task1"
  found = false;
  for i = 1 : numel(events) - 1
    if contains(events(i),'sleep') && ~found
      event = events(i+1);
      found = true;
    end
  end
  if ~found
    error('getEventSleepStamps:MissingSleep','Unable to find sleep event.');
  end
  disp(event)
end
% search for requested event
time_stamps = {};
found = false; stop = false;
for i = 1 : numel(events)
  if contains(events(i),'sleep') && ~stop
    if ~found % if the events has not been found yet
      pos = 1;
    else
      pos = numel(time_stamps) + 1; % if the event has been found, save second sleep and stop
      stop = true;
    end
    % save sleep stamps
    time_stamps{pos,1} = stamps{i};
  elseif events(i) == event && ~stop
    time_stamps{end+1,1} = stamps{i};
    found = true;
  end
end
% error if event was missing in events file
if ~found
  error('getEventSleepStamps:MissingEvent',append('Unable to find event ',event,'.'));
end