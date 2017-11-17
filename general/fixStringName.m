function newStringName = fixStringName(stringName)

% remove spaces and other non standard punctuation marks from strings.
% replace spaces with underscores. Helpful for GVP volcano names
% J. Pesicek

if ~ischar(stringName) && ~iscell(stringName)
    error('bad input')
end

if iscell(stringName)
    if length(stringName)==1
        stringName = char(stringName);
        newStringName = fixStrName(stringName);
        return
    else
%         error('multiple entries not supported')

        for i=1:length(stringName)
           newStringName{i} =  fixStrName(stringName{i});
        end
        return
    end
end
newStringName = fixStrName(stringName);

end

% deal with spaces in string volcano names
function newStrName = fixStrName(strName)

iss=find(isspace(strName));

if ~isempty(iss)
    
    strName(iss) = '_';
    
end

% deal with punctuation marks
isp=find(isstrprop(strName,'punct'));

if ~isempty(isp)
    
    strName(isp) = '';
    
end

newStrName = strName;
end