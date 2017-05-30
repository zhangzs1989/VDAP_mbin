classdef mysqldb
%MYSQLDB Class that handles the management of a Winston MySQL db
% 
%   Designed to work on a Mac
%
% USAGE
% Access a MySQL database by giving it the path to the MySQL program, the
% username, and the password
% >> MDB = mysqldb('/usr/local/mysql-5.6.26-osx10.8-x86_64/bin/mysql',
%  ... 'root', 'lombriz')
%
% Create a time series of when there are data in the MySQL database.
% >> checkdata( MDB, ChannelTag('RC.KBUR..EHZ');
%

    properties
        
        mysqlpath; % path to the mysql program
        mysqluser; % username
        mysqlpass; % password
               
    end
    
    methods
        
        % class constructor
        function obj = mysqldb( path, user, pass )
            
           obj.mysqlpath = path;
           obj.mysqluser = user;
           obj.mysqlpass = pass;
            
        end
        
        % returns dates of data availability for a given channel
        function dates = checkavail( obj, tag )
            
            warning('Can only check availability for one ChannelTag at a time.')
            
            outpath = './mysqltmpout.txt';
            if exist(outpath, 'file'), delete(outpath); end;
            databasestr = ['W_' tag.station '\$' tag.channel '\$' tag.network];
            cmd = [obj.mysqlpath ' -u ' obj.mysqluser ' -p' obj.mysqlpass ' -e "tee ' outpath '; show tables from ' databasestr ';"'];
            [status, result] = system(cmd);
            dates = obj.rdoutfile( outpath );
            
        end
        
        
        % plot availability - give mysqldb obj and tag
        function plotavail2( obj, tag )
            
            warning('Can only plot time series for one ChannelTag at a time.')
            
            avail_dates = checkavail( obj, tag );
            p = plot(datetime(datestr(avail_dates)), ones(size(avail_dates)), 'kx');
            
            % Stylize the plots
            ax = p.Parent;
            ax.YLabel.String = tag.string;
            ax.YLabel.FontWeight = 'bold';
            ax.YTick = [];
            ax.YLabel.Rotation = 0;
            ax.YLabel.HorizontalAlignment = 'right';
            zoom('xon')
            
        end
        
    end
    
    
    methods(Static)
       
        % reads the file written by checkdata;
        % return the dates that are in the file
        function date = rdoutfile( filename )
            %{
            NOTE TO USER: The way this script finds the appropriate lines
            with date data and stores the dates is very crude, but it
            should work.
            
            Here's an example of what the output should look like:

            +--------------------------+
            | Tables_in_w_kbur$ehz$rc  |
            +--------------------------+
            | KBUR$EHZ$RC$$2012_11_11  |  % '$' separates line into four parts; 4th part has format of 'yyyy_mm_dd  |'
                .
                .
                .
            | KBUR$EHZ$RC$$H2012_11_01 | % first letter of 4th part is 'H'
                .
                .
                .
            | kbur$ehz$rc$$hpast2days  | % first letter of 4th part is 'h'
            | kbur$ehz$rc$$past2days   |
            +--------------------------+
            1390 rows in set (0.01 sec)


            %}
                        
            fid = fopen(filename);
            n = 0;
            tline = fgets(fid);
            while tline~=-1
                
                n = n+1;
                tline = fgets(fid);
                if tline~=-1
                    lineparts = strsplit(tline, '$');
                    if numel(lineparts)==4,
                        dateinfo = lineparts{4};
                        if ~strcmpi(dateinfo(1), 'H') ...
                            && ~strcmp(dateinfo(1), 'p')
                            date(n) = datenum(dateinfo, 'yyyy_mm_dd  |');
                        end
                    end
                end
                
            end
            
            fclose(fid);
            delete(filename);
            
            date(date < datenum('1900/01/01')) = [];
            
        end
        
        % plot availability - provide tag and dates
        function plotavail( tag, avail_dates)
            
            warning('Can only plot time series for one ChannelTag at a time.')

            plot(datetime(datestr(avail_dates)), ones(size(avail_dates)), 'kx');
            title(tag.string);
            
        end
           
    end
    
end

