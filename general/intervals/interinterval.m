function c = interinterval( interval, start, stop )
%INTERINTERVAL Given n intervals defined by start/stop pairs interval(n,:)
%and a start value and a stop value, returns the start/stop times of the
%interevent time periods

a = interval;
a(a<start) = start;
a(a>stop) = stop;
b(:,1) = [a(:,1); stop];
b(:,2) = [start; a(:,2)];
c = fliplr(b);
c(c(:,2) <= c(:,1), :) = [];

end

