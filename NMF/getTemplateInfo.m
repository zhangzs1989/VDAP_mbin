function [template_numbers,quakeMLfileList ]= getTemplateInfo(params,inputs)

[quakeMLfileList,~] = readtext(inputs.quakeMLfileList,',','#');

if ~isfield(params,'templates2run')
    template_numbers = [];
elseif strcmpi(params.templates2run,'none')
    template_numbers = [];
elseif strcmpi(params.templates2run,'all')
    if size(quakeMLfileList,2)>1 %here allows for csv with 1st column ID #
        template_numbers = cell2mat(quakeMLfileList(:,1));
    else % create consecutive IDs
        template_numbers = 1:size(quakeMLfileList,1);
    end
else
    if isnumeric(params.templates2run)
        template_numbers = params.templates2run;
    else
        error('templates2run parameter not understood')
    end
end


end