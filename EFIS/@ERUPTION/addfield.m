function e = addfield(e, fieldname, value, noHistOption)
%ADDFIELD Add user defined field to an ERUPTION object
%   Detailed explanation goes here

%%

useHistory = exist('noHistOption','var') && strcmpi(noHistOption,'nohist');
if ischar(fieldname)
    fieldname = {upper(fieldname)}; %convert to cell
else
    error('Waveform:addfield:invalidFieldname','fieldname must be a string')
end

actualfields = upper(fieldnames(e(1))); %get the object's intrinsic fieldnames

if ismember(fieldname,actualfields)
    e = set(e, fieldname{1}, value); %set the value of the actual field
    warning('Waveform:addfield:fieldExists',...
        'Attempted to add intrinsic field.\nNo field added, but Values changed anyway');
    return
end

% Fieldname isn't one that is intrinsic to the eruption object

for n=1:numel(e)                % for each possible eruption
    miscF = e(n).misc_fields;   % grab the misc_fields (cell of fieldnames)
    
    if ~any(strcmp(fieldname,miscF)) % if the field doesn't already exist...
        e(n).misc_fields = [miscF, fieldname]; %add the fieldname to the list
    end
    e(n) = set(e(n), fieldname{1},value);
end
end
