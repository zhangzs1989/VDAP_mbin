function typesOut = LumpAttributes(typesIn,attribute)

if strcmpi(attribute,'Composition')
    
    inp='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_composition2.csv';
    
elseif strcmpi(attribute,'type')
    
    inp='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_morph_types_v2.csv';
    
elseif strcmpi(attribute,'thick')
    
    inp='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_thick.csv';
    
elseif strcmpi(attribute,'plate')
    
    inp='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_plate.csv';    
    
else
    error('BAD attribute')
    
end
%%
[data, ~]= readtext(inp);

allTypes = data(:,1);
cats = data(:,2);

%%
for i=1:length(typesIn)
    
    for j=1:length(cats)
        
        TF = strcmpi(typesIn{i},allTypes{j});
        if TF
            typesOut{i} = cats{j};
            break
        end
        
    end
    
end

if length(typesOut)~=length(typesIn) || sum(isempty(typesOut)) > 0
    error('FATAL')
end

end