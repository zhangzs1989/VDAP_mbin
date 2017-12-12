function getFreqFiltRSAMbyDay(varargin)

%% create frequency filtered RSAM data and save to disk for plotting later

% inputFile = '/Users/jpesicek/Dropbox/VDAP/Responses/Agung/RSAM/rsamInputs.txt';
if nargin == 1
    if exist(varargin{1},'file')
        [inputs,params] = getInputFiles(inputFile);
    else
        error('expected input file')
    end
elseif nargin == 2
    inputs = varargin{1};
    params = varargin{2};
elseif nargin > 2
    error('too many arguments')
end
%%
[CT,~,~,~] = importSwarmStationConfig(inputs.stations);
% CT = channelTag(1:4); %NOTE: here choose channels to do, or edit station file
%%
for i=1:size(params.filters,1)
    fobj(i) = filterobject('b',params.filters(i,:),2);
end
%%
[~,~,~] = mkdir(fullfile(inputs.outDir));
% save([outDir,filesep,'params'],'params')
pts = 24*60/params.rsamWindow;
disp(['RSAM window (s): ',int2str(params.rsamWindow)])

%% TODO: maybe better to parallelize this over day or channel instead of filters
for day = params.startDate:params.endDate
    disp(datestr(day))
    
    for i=1:numel(CT)
        
        disp(CT(i).station)
        try
            
            xt = day:1/pts:day+1;
            xt = xt(1:end-1);
            
            %% loop over filters, PARFOR tested
            parfor j=1:numel(fobj)
                
%                 disp(['BP: ',num2str(get(fobj(j),'cutoff'))])
                [ RSAM_OBJ(j) ] = quickRSAM_JDP( inputs.ds, CT(i), day, day+1, 'mean', params.rsamWindow,fobj(j));
                x = get(RSAM_OBJ(j),'timevector');
                
                if isempty(x) % no data
                    disp('missing data')
                    rsamData = nan(length(xt),1);
                    RSAM_OBJ(j) = set(RSAM_OBJ(j),'data',rsamData);
                    RSAM_OBJ(j) = set(RSAM_OBJ(j),'start',xt(1));                   
                elseif length(x) ~= pts % incomplete data, interpolate
                    r = get(RSAM_OBJ(j),'data');
                    disp('missing data')
                    rsamData = interp1(x,r,xt);
                    RSAM_OBJ(j) = set(RSAM_OBJ(j),'data',rsamData);
                    RSAM_OBJ(j) = set(RSAM_OBJ(j),'start',xt(1));
                end
                
            end
        catch
            error('FATAL')
        end
        str = [datestr(day,'yyyymmdd'),'_',get(CT(i),'station'),'_',get(CT(i),'channel')];
        save(fullfile(inputs.outDir,str),'RSAM_OBJ')
        
    end
end