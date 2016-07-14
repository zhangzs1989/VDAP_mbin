function [dnum, dstr, TJ, TL, VA, VB] = parseEndiAwuFBpost(input_str)
%% PARSEENDIAWUFBPOST Parses Facebook posts from Endi Awu for earthquake rate information

    % stub string
% str = 'Waspada Awu, 30 April 2016 ! Visual : Cuaca terang, angin tenang ! Hujan 29 April 2016 H. Nihil ! G. Awu tampak jelas, asap kawah tidak teramati ( Nihil ) ! Smk. 29 April 2016, 26 x TJ, 2 x TL, 2 x VA dan 10 x VB ! Simpulan : Kegiatan G. Awu masih status Waspada ( Level II ) ! Rekomendasi : Radius 3 Km dari Puncak Awu agar tidak ada Aktifitas/Pengunjung ..... ! Gbr. Visual G. Awu pagi ini, Rekaman Analog dan Digital Gempa Awu 12 Jam terakhir ... !';

    % Translate Indonesian dates to English dates
englishmonths = {'January'; 'February'; 'March'; 'April'; 'May'; 'June'; 'July'; 'August'; 'September'; 'October'; 'November'; 'December'};
idmonths = {'Januari'; 'Februari'; 'Maret'; 'April'; 'Mei'; 'Juni'; 'Juli'; 'Augustus'; 'September'; 'Oktober'; 'November'; 'Desember'};

for m = 1:numel(idmonths)
    
    oldstr = input_str;
    input_str = strrep(oldstr, idmonths{m}, englishmonths{m});
    if ~strcmp(oldstr, input_str), break, end
    
end

    % loop through each string to parse out seismic data
for i = 1:size(input_str,2)
    
    str = input_str{i}
    
        % initialize event counts and date
    dnum(i) = NaN;
    dstr{i} = 'NaN';
    TJ(i) = 0;
    TL(i) = 0;
    VA(i) = 0;
    VB(i) = 0;
    
    
    str(strfind(str, '.')) = [];
    idx.smk = strfind(str,'Smk'); % index of beginning of seismic data
    str2 = str(idx.smk+3:end) % substring starting at the date
    str3 = strsplit(str2,'!') % separate substring into sections, which are separated by '!'
    smkstr = str3{1} % seismic data should be the first section
    smkstr2 = strsplit(smkstr, {',' 'dan'}) % further divide seismic section into event types (should be separated by ',' or 'dan'

        % parse counts for each event type listed
    for n = 1:numel(smkstr2)
        
            % first entry should be the date
        if n == 1
            
            dnum(i) = datenum(smkstr2{n})
            dstr{i} = datestr(dnum)
            
            % all other entries should be counts of different event types
        else
            
            tmpstr = smkstr2{n}
            idx.x = find(tmpstr=='x')
            eventtype = sscanf(tmpstr(idx.x+1:end),'%s')
            counts = sscanf(tmpstr, '%d')
            
            switch eventtype
                
                case 'TJ'
                    
                    display('Tektonik Jauh')
                    TJ(i) = counts
                    
                case 'TL'
                    
                    display('Tektonik Lokal')
                    TL(i) = counts
                    
                case 'VA'
                    
                    display('Vulkanik A')
                    VA(i) = counts
                    
                case 'VB'
                    
                    display('Vulkanik B')
                    VB(i) = counts
                    
                otherwise
                    
                    display('Something went wrong')
                    
                    
            end
            
            
            
        end
        
    end
    
end