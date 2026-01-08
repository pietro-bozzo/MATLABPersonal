function time_stamps = getEventStamps(session,events)
% getEventStamps Get start and stop time stamps for specified consecutive events of a session

arguments
  session (1,:) char
  events (:,1) string
end

% load events file
[event_names,stamps] = loadEvents(session);
% search for required events
j = 1;
for i = 1 : numel(event_names)
  if j <= numel(events) && event_names(i) == events(j)
    time_stamps{end+1,1} = stamps{i};
    j = j + 1;
  end
end
% warn if not all events were found
if j ~= numel(events)
  warning('Unable to find all requested events. Note that they must be given in order.')
end