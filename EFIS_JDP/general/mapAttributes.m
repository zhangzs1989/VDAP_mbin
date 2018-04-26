function volcanoCat = mapAttributes(volcanoCat)

inp1='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_composition3.csv';
inp2='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_morph_types_v2.csv';
inp3='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_thick.csv';
inp4='/Users/jpesicek/Dropbox/Research/EFIS/GVP/gvp_plate.csv';

[data1, ~]= readtext(inp1);
[data2, ~]= readtext(inp2);
[data3, ~]= readtext(inp3);
[data4, ~]= readtext(inp4);
%%
for i=1:numel(volcanoCat)
    
    volcanoCat(i).rock     = mapAttribue(volcanoCat(i).composition,data1);
    volcanoCat(i).morph    = mapAttribue(volcanoCat(i).GVP_morph_type,data2);
    volcanoCat(i).plate    = mapAttribue(volcanoCat(i).tectonic,data3);
    volcanoCat(i).boundary = mapAttribue(volcanoCat(i).tectonic,data4);
   
end

end
%%
function attributeOut = mapAttribue(attributeIn,data)

allTypes = data(:,1);
newTypes = data(:,2);
    
for j=1:length(newTypes)
    
    TF = strcmpi(attributeIn,allTypes{j});
    if TF
        attributeOut = newTypes{j};
        break
    end
    
end
    
end