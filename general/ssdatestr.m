function [ output_args ] = ssdatestr( ss )
%SSDATESTR Displays a n-by-2 matrix of start|stop dates as datestr
%
%
%

%%

for n = 1:size(ss, 1)
    
    t1 = datestr(ss(n,1)); t2 = datestr(ss(n,2)); % convert datenums to datestrs
    duration = diff(ss(n,:)) + 1; % get difference between two dates (add 1 to get correct value; e.g., diff([1 10])=9 but we want the answer 10)
    disp(['      ' t1 '      ' t2 '      (' num2str(duration) ' days)'])
    
end

end

