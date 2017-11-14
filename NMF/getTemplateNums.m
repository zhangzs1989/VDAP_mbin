function template_numbers = getTemplateNums(params,inputs)


if ~isfield(params,'templates2run')
    template_numbers = [];
elseif strcmpi(params.templates2run,'none')
    template_numbers = [];
elseif strcmpi(params.templates2run,'all')
    [qmllist,result] = readtext(inputs.quakeMLfileList,',','#');
    template_numbers = cell2mat(qmllist(:,1));
else
    template_numbers = params.templates2run;
end


end