n = 0;
status = 0;
T = eruptionsT;

for r = 1:height(T)
    
    if strcmpi(T.REMARK{r}, 'Start')
        
        if status == 1            
            stop(n) = start(n);            
        end
        n = n+1;
        start(n) = T.DATETIME(r);
        stop(n) = T.DATETIME(r); % to be replaced by stop
        status = 1;
        
    elseif strcmpi(T.REMARK{r}, 'end') || strcmpi(T.REMARK{r}, 'indefinite')
        if status == 1
            stop(n) = T.DATETIME(r);
            status = 0;
        else
            status = 0;
            warning('End date listed with no apparent start.')
            T(r,:)
        end
        
    elseif isempty(T.REMARK{r})
        if status == 0
            n = n+1;
            start(n) = T.DATETIME(r);
            stop(n) = T.DATETIME(r);
        else
           warning('Empty remark between start and stop flag.')
           T(r,:)
            
        end
        
    elseif strcmpi(T.REMARK{r}, 'Continue')
        % do nothing
    
    else
        warning('I have not programmed anything for a line like this.')
        T(r,:)
        
    end
    
end