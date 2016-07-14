function [F, AMP, PHASE, RESPON] = resp(varargin)
% RESP Calculates instrument response based on a number of inputs
% This program has been translated from SEISAN 10.4.1
% Genius belongs to the creators of SEISAN. Mistakes are mine.
% Translator: Jay Wellik
%
% INPUT (parentheses denote optional fields)
%
% *Leave blank in order to enter SEISAN's interactive input mode
%  or provide the following input:
%
% - (UI) - input parameters for the instrument & digitizer system
% .sensor_type
% .natural_period = 1;
% .damping_ratio = 0.8;
% .generator_constant = NaN;
% (.instrument_description = 'L-4')
% .recording_media_gain = NaN;
% .digitizer_sample_rate = 100;
% .digitizer_model = 'PSN, +/-10v range'; % just a name
% .amplifier_gain = NaN;
% .filt_freqpoles = NaN; % n-by-2 matrix of frequency and number of poles for each filter; negative poles for high pass
% .nfilters = size(i.filt_freqpoles,1);
% .output_format = 'GSE2 PAZ'; % SEISAN FAP | SEISAN PAZ | GSE2 FAP | GSE2 PAZ
%
%
% OUTPUT
% - F           : Frequencies for amplitude and phase calculations
% - AMP         : Amplitude values of response (real numbers)
% - PHASE       : Phase values of response (real numbers)
% - RESPON      : Complex response of the system for NF values
%
% USAGE
%
%

% JJW2 Author Notes
%{
Low Priority Wish List
1) Create a GUI that allows users to enter data (see Fr July 1 for design notes)
%}

%% Initialize

sta=' ';
iyr=0;


%% Text for Options

% SENTXT{1}='NO SENSOR      ';
% SENTXT{2}='SEISMOMETER    ';
% SENTXT{3}='ACCELEROMETER  ';
% RESTXT{1}='DISPLACEMENT   ';
% RESTXT{2}='VELOCITY       ';
% RESTXT{3}='ACCELERATION   ';

% UI = respInput; % set default input values
% original code with default input values:
%{
% npol=0;
% nzero=0;
% norm=1.;
% period=0.;
% DAMPIN=0.;
% GENCON=0.;
% GAIN=0.;
% REGAIN=0.;
% GSEPAZSCALE=1.;
% gse_dig2_samprat=0.;
% gse_dig2_sensitivity=1.;
% amp1hz=0.;
% FFILT = zeros(7); POLE = zeros(7); % initialize seven filters % for i=1:7, FFILT(i)=0; POLE(i)=0; end
% RESTYP = 1;
% RESCOR = 0;
%}

%% FREQUENCIES FOR CALCULATION, ROUND OFF VALUES

NF=60;
F1=0.005;
F2=100.0;
for I = 1:NF % DO 5 I=1:NF
    X=log10(F1)+(I-1)*(log10(F2)-log10(F1))/(NF-1);
    F(I)=10^X;
    if(F(I) <= 0.01 && F(I) > 0.001), K=10000; end
    if(F(I) <= 0.1 && F(I) > 0.01), K=1000; end
    if(F(I) <= 1.0 && F(I) > 0.1), K=100; end
    if(F(I) <= 10.0 && F(I) > 1.0), K=10; end
    if(F(I) >= 10.0), K=1; end
    J=F(I)*K+0.5;
    F(I) = J/K; %F(I)=J/FLOAT(K)
%     5    CONTINUE
end
    
%%   PUT 1 HZ RESPONSE IN NUMBER 61

F(61)=1.0;
NF=61;
      
%% Parse User Input
% Rename input parameters to match SEISAN code
% This corresponds to the section of SEISAN code that collects user input
% (starts with 'ENTER OUTPUT FORMAT')
% This code corresponds to the block 'ENTER OUTPUT FORMAT'

if nargin==0 % no input parameters are given; prompt user for interactive input
    
    UI = interactiveInput();
 
elseif nargin==1
    % assume the 1 and only input argument is a structure of all necessary arguments
    
    UI = parseInputFile(varargin{1});
    
end

    % strip UI from names
outtyp = UI.outtyp;
gse_cal2_instype = UI.gse_cal2_instype;
SENTYP = UI.SENTYP;
PERIOD = UI.PERIOD;
DAMPIN = UI.DAMPIN;
GENCON = UI.GENCON;
GAIN = UI.GAIN; % doesn't the prompt say that the default value is 1?
REGAIN = UI.REGAIN;
GSEPAZSCALE = UI.GSEPAZSCALE;
gse_dig2_description = UI.gse_dig2_description;
gse_dig2_samprat = UI.gse_dig2_samprat;
gse_dig2_sensitivity = UI.gse_dig2_sensitivity;
NFILT = UI.NFILT;
FFILT = UI.FFILT;
POLE = UI.POLE;
RESTYP = UI.RESTYP;
RESCOR = UI.RESCOR;
norm = UI.norm;
npol = UI.npol;
nzero = UI.nzero;
nresp = UI.nresp;

%% STUB VALUES

PAZ = false; % this shouldn't be set here
GSE = false; % this shouldn't be set here

%% ENTER HERE FOR RECALCULATION FROM END OF PROGRAM
%------------------------------------------------------------
%------------------------------------------------------------

%  2000 continue

NF=61;  % to get 1 hz again if recal

%      
%   NOW READY FOR CALCULATIONS, FIRST CALCULATE CONSTANT FACTORS  
%

FACTOR=1.0;

%
%  AMP GAIN AND RECORDING MEDIA GAIN
%

FACTOR=FACTOR*10^(GAIN/20.0)*REGAIN;

%
%  SEISMOMETER IF ANY
%
if ~PAZ
    if(SENTYP==2)
        FACTOR=FACTOR*GENCON;
        %          FACTOR=FACTOR*PI*(0.0,2.0)*GENCON*(-1.0)*PERIOD**2 ! before mar 2000
    end
    %
    %  ACCELEROMETER IF ANY, DO CONVERSION OF G TO M/SS
    %
    if(SENTYP==3), FACTOR=FACTOR*GENCON/9.81; end
end

%%
%
% response in PAZ
%

if PAZ
    
    omega0=2.*pi/PERIOD;
    
    %
    % norm in Counts/m
    %
    %        norm=norm*10^(GAIN/20.0)*REGAIN   % norm=1.
    GSEPAZSCALE=norm*1E-09;   % norm may be set if paz file m to nm
    norm=norm*10^(GAIN/20.0)*REGAIN;
    %        write(6,*)'norm,gain,regain:',norm,gain,regain
    gse_dig2_sensitivity=10^(GAIN/20.0)*REGAIN;
    
    switch SENTYP
        
        case {2, 4} % {'seismometer','mechanical displacement seismometer'}
            % joint settings for seismometer and mechanical displacement seismometer
            
            norm=norm*GENCON;    % Seisan
            gse_paz2_sfactor= GENCON * GSEPAZSCALE;     % c/m -> c/nm
            ppr(npol+1)=-DAMPIN*omega0;
            ppi(npol+1)=sqrt(1.-DAMPIN^2)*omega0;
            pol(npol+1)=complex(ppr(npol+1),ppi(npol+1));
            
            ppr(npol+2)=-DAMPIN*omega0;
            ppi(npol+2)=-sqrt(1.-DAMPIN^2)*omega0;
            pol(npol+2)=complex(ppr(npol+2),ppi(npol+2));
            
            npol=npol+2;
            zero(nzero+1)=complex(0.,0.);
            zero(nzero+2)=complex(0.,0.);
            
            switch SENTYP
                % adjust settings for particular instrument type
                
                case 2 % 'seismometer'
                    zero(nzero+3)=complex(0.,0.);
                    nzero=nzero+3;
                    
                case 4 %'mechanical displacement seismometer'
                    nzero=nzero+2;
                    
            end
            
        case 3 % 'accelerometer'
            % accelerometer settings
            
            norm=norm*GENCON/9.81;   % Seisan
            gse_paz2_sfactor=GENCON/9.81 * GSEPAZSCALE;    % c/m -> c/nm
            zero(nzero+1)=complex(0.,0.);
            zero(nzero+2)=complex(0.,0.);
            nzero=nzero+2;
            
        case 1 % 'none'
            % default settings for no instrument type
            
            gse_paz2_sfactor = GSEPAZSCALE
            
        otherwise
            
            error('''SENTYP'' not undertsood while trying to normalize');
            
    end
    
    %
    % get poles and zeros for Butterworth filters, same as routine
    % bworth, but gives paz instead of the transfer function
    %
    %    the formulas used --
    
    %{
    %
    %    lowpass:      h(s)=1/(s-s1)(s-s2)...(s-sk)
    %    where poles   sk=omega0*exp(i*pi*(1/2+((2*k-1)/(2*np))))
    %                                   k=1,2, ... number of poles
    %                  s = i omega
    %                  norm = norm * omega0
    %    highpass:     h(s)=z**k/(s-s1)(s-s2) ....
    %    where poles   sk=omega0/exp ...
    %
    %}
    
    % possibly make this block a subroutine called normForSENTYPnone??
    if NFILT > 0
        for it=1:NFILT
            fc=FFILT(it)*2*pi;
            k=abs(POLE(it));
            for j=1:abs(POLE(it))
                w=pi*(0.5+((2*j-1)/(2*k))); % w=pi*(0.5+((2.*float(j)-1.)/(2.*float(k))));
                cw=complex(0,w);
                
                % separate settings for low and high pass filtersr
                if pole(it) > 0 % low pass filter
                    norm=norm*fc;
                    gse_paz2_sfactor = gse_paz2_sfactor*fc;
                    pol(npol+1)=fc*cexp(cw);
                    npol=npol+1;
                else % high pass filter
                    pol(npol+1)=fc/cexp(cw);
                    npol=npol+1;
                    zero(nzero+1)=complex(0,0);
                    nzero=nzero+1;
                end
                
            end
        end
    end
    
end


%%
%
%  ENTER LOOP OF NF PREDEFINED FREQUENCES TO CALCULTE REPONSE
%  INITIALLY DISPLACEMENT FOR SEISMOMETER AND ACCELERATION FOR
%  ACCELEROMETER
%   
for I=1:NF % for 100 I=1:NF
    %
    if ~PAZ
        %
        %   SEISMOMETER
        %
        %                                  REGAIN[V/m/s] * GENCON * s^3
        % T(s)= preamplification *  ----------------------------------------------
        %                                 s^2 + 2*h*omega0*s + omega0^2
        %
        %   T(j omega) = T(s) for s -> j omega
        %
        
        
        %           RESPON(I)=FACTOR         ! before mar 00
        
        switch SENTYP
        
            case 1 % 'none'
            RESPON(I)=FACTOR;
            
            case {2, 4} % 'seismometer' or 'mechanical displacement seismometer'
            %
            % CLEANED UP IN MARCH 2000 lo
            %
            X=PERIOD*F(I);
%             RESPON(I)=FACTOR*(0,2)*pi*PERIOD^2*(-1)*F(I)^3/(1+(0,2)*DAMPIN*X-X*X);
            RESPON(I)=FACTOR*[0,2]*pi*PERIOD^2*(-1)*F(I)^3/(1+[0,2]*DAMPIN*X-X*X);
            
            %formula:
            %{
            %
            %  this is the same as:
            %
            %                          - i * (om)^3
            %         RESPON(om) = ---------------------------
            %                       om0**2 - om^2 +2*h*om*om0
            %
            %  where om=2*pi*f, om0 = 2*pi*f0,  f=/T, f0=1/T0
            %
            %  the minus sign in the nominator comes from the generator constant
            %  or, if polarity has put so, is there to make sure a positive pilse gives
            %  a positive first motion
            %
            %}
            
            % RESPON(I)=RESPON(I)*F(I)**3/(1.+(0.,2.)*DAMPIN*X-X*X) ! before aug96
            % RESPON(I)=RESPON(I)*F(I)**3/(1.-(0.,2.)*DAMPIN*X-X*X) ! until mar 00
            
            case 3 % 'accelerometer'
            RESPON(I)=FACTOR;
            
            otherwise
                
        end
        
        %
        %   FILTERS
        %
        if NFILT > 0
            for J = 1:NFILT % DO 20, J=1:NFILT
                
                %CALL BWORTH(F(I),FFILT(J),POLE(J),CX) % freq, corner freq, number of poles, complex resp of filter
                
                % Possible Matlab replacement?
                if POLE(J) >= 0, type = 'low'; else type = 'high'; end %% what happens if np = 0?
%                 [CX(:,1), CX(:,2)] = butter(POLE(J), F(I), type); % is the output coded correctly?
                CX = bworth(F(I), F(I), NFILT);
                
                RESPON(I)=RESPON(I)*CX;
            end %20           CONTINUE
        end
    end
    
    %
    %   MULTIPLY WITH ANOTHER RESPONSE CURVE WHICH CAN BE POLES AND ZERO'S
    %   if available, if only paz used, that is all which is done, if paz
    %   are additional to fap, multiply with earlier fap values
    %
    
    if( npol ~= 0 || nzero ~= 0 )
        presp = pazresp(F(I), norm, nzero, zero, npol, pol); % call pazresp (f(i), norm, nzero, zero, npol, pol, presp)
        if ~(PAZ)    % fap
            RESPON(I)=RESPON(I)*presp;
        else
            RESPON(I)=presp;     % paz
        end
    else
        if (PAZ)
            RESPON(I)=norm;
        end
    end
    
    %
    %   interpolate in tabulated values
    %
    if(nresp > 2)
%         call inter_p(nresp,normtab,
%         *     freq_val,gain_val,phas_val,f(i),presp)
        RESPON(I) = inter_p(nresp, normtab, freq_val, gain_val, phas_val, F(I), presp);
        RESPON(I)=RESPON(I)*presp;
    end
    
    %
    %   COMPLEX RESPONSE FINISHED, CALCULATE REAL RESPONSE
    %   TAKING INTO CONSIDERATION THE TYPE OF RESPONSE WANTED
    %
    AMP(I)= abs(RESPON(I))/((2*pi*F(I))^RESCOR);
    X=imag(RESPON(I));
    Y=real(RESPON(I));
    if(Y == 0.0)
        PHASE(I)=0.0;
    else
        PHASE(I)=(atan2(X,Y)-(pi/2.0)*RESCOR)*(180/pi);
    end
end % 100  CONTINUE

%% FINISHED RESPONSE CALCULATION. NORMALIZE TO 1.0 AT 1 HZ AND SAVE 1HZ VALUE

AMP1HZ=AMP(61);

%% FINISHED WITH 1 HZ, NF BACK TO 60

% NF=60;
% for I=1:NF %      DO 110 I=1,NF
%     AMP(I)=AMP(I)/AMP1HZ;
% end % 110  CONTINUE
AMP = AMP/AMP1HZ; % vectorized for Matlab


%% CHECK IF MANUAL POINTS SHOULD BE USED FOR COMPARISON

%{
      if ~recal
         WRITE(6,*)
     *   ' FILE NAME FOR MEASURED VALUES, RETURN FOR NO FILE '
         READ(5,'(A20)') MANFIL
         MNF=0
         if(MANFIL~='                    ')
            OPEN(3,FILE=MANFIL,STATUS='OLD')
            I=1
 30         CONTINUE
            READ(3,*,END=40)MF(I),MAMP(I),MPHASE(I)
            I=I+1
            GOTO 30
 40         CONTINUE
            MNF=I-1
            WRITE(6,*) MNF,' VALUES READ IN'
         end
      end
%}
      
%% FILE WRITING AND PLOTTING STUFF (?)      
%{
%
%   OUTPUT IN FILE
%

      OPEN(2,FILE='resp.out',STATUS='UNKNOWN')
      WRITE(2,220)SENTXT(SENTYP),RESTXT(RESTYP)
 220  FORMAT('  SENSOR TYPE: ',A15,3X,'RESPONSE: ',A15) 
      WRITE(2,*)' SEISMOMETER PERIOD=', PERIOD
      WRITE(2,*)' GENERATOR CONSTANT=', GENCON
      WRITE(2,*)' DAMPING RATIO     =', DAMPIN
      WRITE(2,*)' AMPLIFIER GAIN(DB)=', GAIN
      WRITE(2,*)' RECORDING GAIN=    ', REGAIN
      if ~(strcmp(FILEPOLE(1:3),'   ')) 
     *write(2,'(a,a)') 
     *'  FILE WITH POLES AND ZEROS: ',FILEPOLE
      if~(strcmp(FILETAB(1:3),'   ')) 
     *write(2,'(a,a)') 
     *'  FILE WITH TABULATED VALUES: ',FILETAB
      if(NFILT >= 1)
         WRITE(2,*)' FILTER CONSTANTS' 
         WRITE(2,200) (FFILT(I),POLE(I),I=1,NFILT)
 200     FORMAT(1X,' F=',F6.2,3X,'POLES=',I3)
      end
      WRITE(2,*)' GAIN AT 1 HZ=      ', AMP1HZ
      WRITE(2,*) 
      WRITE(2,201)(F(I),1.0/F(I),AMP(I),
     *20*ALOG10(AMP(I)),PHASE(I),I=1,NF)
 201  FORMAT
     *(1X,'F=',F8.4,3X,'T=',F8.2,3X,' AMP=',F14.6,3X,
     *' AMPDB=',F6.1,3X,' PHAS=',F8.1)

%
%   FINISHED, TAKE LOG BEFORE PLOTTING
%

       DO 130 I=1,NF
         LAMP(I)=ALOG10(AMP(I))
         LF(I)=ALOG10(F(I))
 130  CONTINUE
      DO 135 I=1,MNF
         MAMP(I)=ALOG10(MAMP(I))
         MF(I)=ALOG10(MF(I))
 135  CONTINUE
%}
      
%% BEGINNING OF PLOTTING AND FILE WRITING (?)
%{
%
%   PLOT AMPLITUDE RESPONSE
%

      WRITE(6,*)     
      XTEXT='FREQ  '
      YTEXT='AMPL    '  
      WRITE(6,221) SENTXT(SENTYP),RESTXT(RESTYP)
 221  FORMAT(12X,' AMPLITUDE RESPONSE',3X,A15,3X,A15) 
      CALL PLOTW(MNF,NF,MF,MAMP,LF,LAMP,XTEXT,YTEXT,1,1)
      WRITE(6,'(a,G10.3,2x,a,$)')' GAIN FACTOR AT 1 HZ:',AMP1HZ,
     *'   RETURN FOR PHASE RESPONSE'
      READ(5,'(A)') X 
      
%
%   PLOT PHASE RESPONSE                   
%

      YTEXT='PHAS DEG'
      WRITE(6,222) SENTXT(SENTYP),RESTXT(RESTYP)
 222  FORMAT(12X,' PHASE RESPONSE',3X,A15,3X,A15) 

      CALL PLOTW(MNF,NF,MF,MPHASE,LF,PHASE,XTEXT,YTEXT,1,0)
%
%----------------------------------------------------------------
%  OPTION FOR SEISAN RESPONSE  FILE
%-----------------------------------------------------------------
%
      if (outtyp == 0) then
        WRITE(6,*) ' RESPONSE CURVE IS IN FILE resp.out'
        write(6,*) ' NO CALIBRATION FILE CREATED '
        stop
      end
      if (outtyp == 1 | outtyp == 2) then
        WRITE(6,'(a,$)')' SEISAN RESPONSE FILE (Y/N=default)?'
      else
        WRITE(6,'(a,$)')' GSE RESPONSE FILE (Y/N=default)?'
      end
        
      READ(5,'(a1)') ANSWER
      if(ANSWER~='Y' & ANSWER~='y'), GOTO 999; end
%
%   MUST BE DISPLACEMENT, CHECK
%
      if(RESTYP~=1)
         WRITE(6,*)' RESPONSE TYPE MUST BE DISPLACMENT'
         GOTO 999
      end

%
%  questions, skip if recal unless parameter not given previously
%
      if(recal & sta~=' ' & iyr~=0), goto 3000; end
%
      print*,'Enter station code. e.g. BERGE, max 5 chars '
      read(5,'(a)')sta
 666  continue
      print*,' Enter component (4 chars) e.g. SH Z'
      print*,
     *' First character is type, should be one of the following: '
      print*,' E, S, H, B, M, L, U '
      Print*,
     *' Second character is instrument code,',
     *' should be one of the following: '
      print*,' H, L, G, M, N'
      print*,' Third character is not used, leave blank'
      print*,' Last character is orientation, must be Z,N or E'
%      print*,'Character 2 and 3 can be anything'
      read(5,'(a4)')comp
      if(comp(4:4)~='N' & comp(4:4)~='E' & comp(4:4)~='Z')
        write(6,*)' Wrong orientation, redo'
        goto 666
      end
%
%      if(sentyp == 3 & comp(1:1)~='A') then
%         comp(1:1)='A'
%         write(6,*)
%     *' Sensor is an accelerometer, first letter of component must be A'
%         write(6,'(a,a)') ' Component changed to ',comp
%      endif
      write(6,'(1x,a,a,$)')
     *'Enter date as YYYYMMDDHHMMSS, at least up to the day ',
     *' (e.g. 19880123):'
      read(5,'(i4,5i2)')iyr,imon,idy,ihr,imin,isec
      sec=float(isec)
%
%   get doy
%
      call date_doy(idoy,idy,imon,iyr)
      ielev=-999
      alat=999
      alon=999
%
% get some input, SEISAN
%
      if (outtyp == 1 | outtyp == 2)
        write(6,'(1x,a,a,$)')'Latitude (Up to 4 ',
     *'decimal places and - for south), return for none:'
        read(5,'(a)') text
        if(text(1:2)~='  ')
           call sei get values(1,text,code)
           alat=array$(1)
        end
        write(6,'(1x,a,a,$)')'Longitude (Up to 4 ',
     *'decimal places and - for west), return for none:'
        read(5,'(a)') text
        if(text(1:2)~='  ')
           call sei get values(1,text,code)
           alon=array$(1)
        end
        write(6,'(1x,a,a,$)')'Enter elevation in meters (integer), ',
     *'return for none:'
        read(5,'(a)') text
        if(text(1:2)~='  ')
           call sei get values(1,text,code)
           ielev=array$(1)
        end
        write(6,*)'Enter comments, one line. e.g. amp type, sensor type',
     *' return for none'
        read(5,'(a80)') comment
      end
%
%   enter here if question skipped for recal, just above
%
 3000 continue
%
%
%   make file name
%
      file=' '
      file(1:5)=sta(1:5)
      file(6:9)=comp(1:4)
      do i=1,9
        if(file(i:i) == ' ' | file(i:i) == char(0)) file(i:i)='_'
      enddo
      file(10:10)='.'
      write(file(11:25),150)iyr,imon,idy,ihr,imin
 150  format(i4,'-',i2,'-',i2,'-',2i2)

      if (outtyp == 1 | outtyp == 2) then
        file(26:29)='_SEI'
      elseif (gse) then
        file(26:29)='_GSE'
      end
      for i=11:25
        if(file(i:i) == ' ') file(i:i)='0'
        end
%
      open(4,file=file(1:seiclen(file)),status='unknown')


      if (outtyp == 1 | outtyp == 2)
%
%--------------------------------------------------------------
%   SEISAN RESPONSE FILE
%--------------------------------------------------------------
%
      do 64 i=1,1040
         header(i:i)=' '
 64   continue

%  
%   CONSTANTS
%
%   indicator TC for force use of tabulated values if:
%   1. combined response of poles and zeros and parameters, fab wanted
%   2. combined rersponse with tabulated values
%   3. number of poles and zero larger than 37 since not enough room in format
%

      if(((npol+nzero) > 0 & (gencon > 0.0 | nfilt ~= 0 | regain ~= 1.0 | gain ~= 0) & ~paz) ...
              | nresp > 0 | (npol+nzero) > 37) header(78:79)='TC'

%
      WRITE(HEADER(161:240),'(f8.3,f8.4,f8.1,f8.1,
     *2G8.3,2(g8.3,f8.3))')
     *PERIOD,DAMPIN,GENCON,GAIN,REGAIN,AMP1HZ,
     *FFILT(1),FLOAT(POLE(1)),FFILT(2),FLOAT(POLE(2))
      WRITE(HEADER(241:320),'(5(G8.3,f8.2))')(FFILT(I),
     *FLOAT(POLE(I)),I=3,7)   
%
%  RESPONSE VALUES
%
        do 60 i=1,3
          j1=(i-1)*20 + 1
          j2=j1+19
          i1=320+(i-1)*240+1
          i2=i1+79
          i3=400+(i-1)*240+1
          i4=i3+79
          i5=480+(i-1)*240+1
          i6=i5+79
          write(header(i1:i2),'(10g8.3)')(f(j),j=j1,j2,2)
          write(header(i3:i4),'(10g8.3)')(amp(j),j=j1,j2,2)
          write(header(i5:i6),'(10f8.3)')(phase(j),j=j1,j2,2)
 60     continue
%
%   if only poles and zeros are given and less than 38 together, 
%   use that instead of table values, indicate with P. If combined
%   response has been calculated, do not use poles and zeros.
%
        if(header(79:79) == ' '.and.paz.and.(npol+nzero) < 38)
         header(78:78)='P'   % indicate poles and zeros
         for i=161:1040
            header(i:i)=' '
         end
         write(header(161:182),'(1x,2i5,g11.4)') npol,nzero,norm
         k=23
         line=3
%        do i=1,npol*2
         for i=1:npol          %jh jan 06
%           write(chead(line)(k:k+10),'(g11.4)') ppr(i)
            write(chead(line)(k:k+10),'(g11.4)') real(pol(i))
            k=k+11
            if(k == 78)
              k=1
              line=line+1
            end
%           write(chead(line)(k:k+10),'(g11.4)') ppi(i)
            write(chead(line)(k:k+10),'(g11.4)') aimag(pol(i))
            k=k+11
            if(k == 78)
              k=1
              line=line+1
            end
         end
%        do i=1,nzero*2
         for i=1:nzero     % jh jan 06
%           write(chead(line)(k:k+10),'(g11.4)') pzr(i)
            write(chead(line)(k:k+10),'(g11.4)') real(zero(i)) 
            k=k+11
            if(k == 78)
              k=1
              line=line+1
            end
%           write(chead(line)(k:k+10),'(g11.4)') pzi(i)
            write(chead(line)(k:k+10),'(g11.4)') aimag(zero(i))
            k=k+11
            if(k == 78) then
              k=1
              line=line+1
            end
         end
        end

%
%  put in header, first blank
%
      header(1:5)=sta(1:5)
      header(6:9)=comp(1:4)
      if(alat~=999.), write(header(52:59),'(f8.4)')alat; end
      if(alon~=999.), write(header(61:69),'(f9.4,i5)')alon; end
      if(ielev~=-999), write(header(71:75),'(i5)')ielev; end
      k=iyr-1900 % century info in 3 digits
      write(header(10:35),'(i3,1x,i3,4(1x,i2),1x,f6.3)')k,idoy,
     *imon,idy,ihr,imin,sec
      write(header(81:160),'(a80)')comment(1:80)
%
%   write out
%     
      do 70, i=1,13
        j=(i-1)*80+1
        write(4,'(a80)')header(j:j+79)   
 70   continue      

%
% write GSE2 output
%

%
% PAZ
%    
      elseif (gse)

%
%   get def file for station codes, give file name
%
        deffile='gsesei.def'
        no_net = .FALSE.
        net_code=' '
        call read_def_chan(deffile,mainhead_text,net_code)
        gse_stage=1

%
% header line, CAL2 
% 
        gsetext(1:96)='                                        '
     &// '                                                        '
        gsetext(1:4)='CAL2'
        gsetext(6:10)=sta(1:5)

%
% convert component to GSE
%
        call set_def_chan(1,sta,comp)
        if (seiclen(comp) > 3) then
          gsetext(12:13)=comp(1:2)
          gsetext(14:14)=comp(4:4)
        else
          gsetext(12:14)=comp(1:3)
        end
        gsetext(21:26)=gse_cal2_instype

        if (outtyp == 3)
%         write(gsetext(28:42),'(e10.2)') 1e9/amp1hz        ! GSE2.1
          write(gsetext(28:37),'(e10.2)') 1e9/amp1hz        
        else
%         write(gsetext(28:42),'(e10.2)') 1.                ! GSE2.1
%
% product of all stage scaling factors, in nm/count
%
          write(gsetext(28:37),'(e10.2)') 1e9/amp1hz        
% changed lo, july 13, 2001
%          write(gsetext(28:37),'(e10.2)') 
%     &           1/(gse_paz2_sfactor*gse_dig2_sensitivity)
        end
        write(gsetext(44:45),'(a2)') '1.'
% sample rate, added lo July 13, 2001
        write(gsetext(47:56),'(f10.5)') gse_rate

        write(gsetext(58:67),'(i4.4,a1,i2.2,a1,i2.2)') 
     &       iyr,'/',imon,'/',idy
        write(gsetext(69:73),'(i2.2,a1,i2.2)') ihr,':',imin

        write(4,'(a96)') gsetext
%
% paz line, stage 1
%

        gsetext(1:96)='                                        '
     &// '                                                        '
        if (outtyp == 3)
          gsetext(1:6)='FAP2  '
          gsetext(26:27)='60'
ccc changed lo 7/12/2010
        elseif (outtyp == 4)
          gsetext(1:6)='PAZ2  '
          write(gsetext(11:25),'(e15.8)') gse_paz2_sfactor
          write(gsetext(41:43),'(i3)') npol
          write(gsetext(45:47),'(i3)') nzero
          write(gsetext(49:65),'(a17)') 'Laplace transform'
        end
        write(gsetext(7:7),'(i1)') gse_stage
        gsetext(9:9)='V'             % Volts
        write(4,'(a96)') gsetext
        if (outtyp == 3) then
          for i=1:60
            write(4,'(1x,f10.5,1x,e15.8,1x,i4)') f(i),amp(i),
     &            int(phase(i))
          end
        else
          for i=1:npol
            write(4,'(1x,e15.8,1x,e15.8)') real(pol(i)),
     &      aimag(pol(i))
          end
          for i=1:nzero
            write(4,'(1x,e15.8,1x,e15.8)') real(zero(i)),
     &      aimag(zero(i))
          end
        end
%
% digitizer DIG2, stage 2
%
        gse_stage=gse_stage+1
        if (outtyp == 4)
          gsetext(1:96)='                                        '
     &// '                                                        '
          gsetext(1:6)='DIG2  '
          write(gsetext(7:7),'(i1)') gse_stage
          write(gsetext(9:23),'(e15.8)') gse_dig2_sensitivity
          write(gsetext(25:35),'(f11.5)') gse_dig2_samprat
          gsetext(37:61)=gse_dig2_description

          write(4,'(a96)') gsetext
        end
      end
%
% fir filters
%
      if (nfirstage > 0)
        for i=1:nfirstage
          gse_stage=gse_stage+1
          for k=1:nfir(i)
            rfir(k)=fir(i,k)
          end
          if(abs(1.-normalize_fir(nfir(i),rfir,fir_rate(i))) > .01)
            write(*,*) ' Warning: fir filters not normalized '
          end
          if (nfir(i) > 0)
            gsetext(1:80) = ...
                '                                        ' ...
                '                                        ';
            gsetext(1:4)='FIR2'
            write(gsetext(6:7),'(i2)') gse_stage
            write(gsetext(9:18),'(e10.2)') 1. % changed lot12/2/2008
%     &   normalize_fir(nfir(i),rfir,fir_rate(i))
            write(gsetext(20:23),'(i4)') fir_deci(i)
            write(gsetext(25:32),'(f8.3)')delay_fir(nfir(i),fir_rate(i))
%            gsetext(34:34) = sym_fir(nfir(i),rfir)
            gsetext(34:34) = fir_sym(i)
            write(gsetext(36:39),'(i4)') nfir(i)
            write(4,'(a80)') gsetext(1:80)
            for j=1:nfir(i)':5
              gsetext(1:80) = ...
               '                                        ' ...
               '                                        '
              write(gsetext(1:80),'(5(1x,e15.8))') ...
                fir(i,j),fir(i,j+1),fir(i,j+2),fir(i,j+3),fir(i,j+4);
%
% remove 0s from last line
%
              if (j == nfir(i) & mod(nfir(i),5)~=0)
                for k=mod(nfir(i),5):4
                  write(gsetext(16*k+1:16*k+16),'(a16)')
     &              '                '
                end
              end
              write(4,'(a80)') gsetext(1:80)
            end
          end
        end
      end
       
      close(4)
%
%   plot
%
      call systemc('presp '//file(1:seiclen(file)),seiclen(file)+6)
%
%------------------------------------------------------------------------
% parameters for recalculation   
%-------------------------------------------------------------------------
%
cxx 999  CONTINUE
      recal=false
 990  continue
      write(6,*)' Constants used:'
      write(6,*)
      WRITE(6,'(a,f13.2)')' 1: SEISMOMETER PERIOD=', PERIOD
      WRITE(6,'(a,f13.2)')' 2: GENERATOR CONSTANT=', GENCON
      WRITE(6,'(a,f13.2)')' 3: DAMPING RATIO     =', DAMPIN
      WRITE(6,'(a,f13.2)')' 4: AMPLIFIER GAIN(DB)=', GAIN
      WRITE(6,'(a,f13.0)')' 5: RECORDING GAIN=    ', REGAIN
      write(6,'(a,a,a)')  ' 6: STATION AND COMP=  ', sta,comp
      write(6,'(a,i4,5i2)')  ' 7: DATE AND TIME=     ',
     *                         iyr,imon,idy,ihr,imin,isec
      IF(NFILT >= 1) THEN
         WRITE(6,'(a)')   ' 8: FILTER CONSTANTS' 
         WRITE(6,200) (FFILT(I),POLE(I),I=1,NFILT)
      ENDIF
      write(6,*)
      write(6,*)
     *' Run again: Enter number to change value, enter to end'
      write(6,*)' End: Enter' 
%
      read(5,'(a)') text
      if(text(1:1)~=' ')
         read(text(1:1),'(i1)') k
         if(k > 8)
            write(6,*)' Not a valid number'
            goto 990
         end
         recal=true
         if(k == 1)
            write(6,*)' SEISMOMETER NATURAL PERIOD'
            read(5,*) PERIOD
            goto 990
         end
         if(k == 2)
            write(6,*)' SENSOR LOADED GENERATOR CONSTANT'
            read(5,*) GENCON
            goto 990
         end
         if(k == 3)
            write(6,*)' SEISMOMETER DAMPING RATIO'
            read(5,*) DAMPIN
            goto 990
         end
         if(k == 4)
            write(6,*)' AMPLIFIER GAIN(DB)'
            read(5,*) GAIN
            goto 990
         end
         if(k == 5)
            write(6,*)' RECORDING MEDIA GAIN'
            read(5,*) REGAIN
            goto 990
         end
         if(k == 6)
            print*,'Enter station code. e.g. BERGE, max 5 chars '
            read(5,'(a)')sta
 667        continue
            print*,'Enter component (4 chars) e.g. SL Z'
            print*,
     *      '  First character is type, must be one of the following: '
            print*,'  S: Short period, L: Long period'
            print*,'  B: Broad band,   A: Accelerometer'
            print*,'Last character must be Z,N or E'
            print*,'Character 2 and 3 can be anything'
            read(5,'(a4)')comp
            if( comp(1:1)~='S' & comp(1:1)~='L'.
     *      and.comp(1:1)~='B'.
     *      and.comp(1:1)~='A' & comp(4:4)~='N'.
     *      and.comp(4:4)~='E'.
     *      and.comp(4:4)~='Z') then
               write(6,*)' Wrong component, redo'
               goto 667
            endif
            if(sentyp == 3 & comp(1:1)~='A') then
              comp(1:1)='A'
              write(6,*)
     *        ' Sensor is an accelerometer, first letter',
     *        ' of component must be A'
               write(6,'(a,a)') ' Component changed to ',comp
             endif
             goto 990
         endif
         if(k == 8) then
            WRITE(6,*) ' NUMBER OF FILTERS (0-10), RETURN FOR NONE ? '
            READ(5,'(a)') TEXT
            IF(TEXT(1:2) == '  ') THEN
              NFILT=0
            ELSE
              CALL SEI GET VALUES(1,TEXT,CODE)
              NFILT=ARRAY$(1)
            ENDIF
            IF(NFILT > 0) THEN
               WRITE(6,*)
     *         ' FREQUENCY AND NUMBER OF POLES FOR EACH FILTER,'
               WRITE(6,*)' POLES NEGATIVE FOR HIGH PASS '
               DO  I=1,NFILT
                  READ(5,*) FFILT(I),POLE(I)
               enddo
            ENDIF
            goto 990
         endif
         if(k == 7) then
            write(6,'(1x,a,a,$)')
     *      'Enter date as YYYYMMDDHHMMSS, at least up to the day ',
     *      ' (e.g. 19880123):'
             read(5,'(i4,5i2)')iyr,imon,idy,ihr,imin,isec
             sec=float(isec)
%
%   get doy
%
             call date_doy(idoy,idy,imon,iyr)
             goto 990
         endif
      else
         if(recal) then
            goto 2000   ! recalculate
         endif
      endif
 999  continue

      write(6,*)' '
      write(6,'(a,a)')' Response file name is: ',file(1:seiclen(file))
      WRITE(6,*)' RESPONSE CURVE IS IN FILE resp.out'
      STOP
      END


%
      SUBROUTINE PLOTW(N1,N2,X1,Y1,X2,Y2,XTEXT,YTEXT,XLOG,YLOG)           
%
%   J. HAVSKOV SOMETIMES IN 1978 IN MEXICO WHEN WE HAD NO PLOTTER
%   HAS BEEN CHANGED A BIT FOR CURRENT VERSION (1990) 
%
%                                                                       
%   ROUTINE TO PLOT ON A LINE PRINTER 2 SETS OF DATA                    
%   Y AS A FUNCTION X ON ONE PAGE, DIMENSION NXDIM*NYDIM                     
%   THERE ARE N1 AND N2 POINTS IN THE TWO DATA SETS X1,Y1 AND           
%   X2,Y2 RESPECTIVELY. THE OUTLINE OF THE PLOT IS                      
%   DETERMINED BY THE MAX AND MIN VALUES IN THE DATA SET 2              
%   AND VALUES X1,Y1 OUTSIDE THE GRID WILL NOT BE USED.                 
%   IF N1 = 0 ,DATA SET X1-Y1 IS NOT USED                               
%   THE X AND Y VALUES CAN COME IN ANY ORDER, THEY                      
%   WILL AUTOMATICALLY BE SCALED.                                       
%   IF XLOG OR YLOG=1, LOG SCALE FOR AXIS NUMBERS, ELSE LINEAR
%                                                                       
%   number of digits to be printed must
%   be fixed in the the format statement. Likewise if numbers
%   printed out should be log or antilog
%                                                                       
      DIMENSION X1(*),Y1(*),X2(*),Y2(*)             
      DIMENSION YSC(41),XSC(11)
      CHARACTER*1 A(101,41)
      CHARACTER*8 YTEXT
      CHARACTER*6 XTEXT                                         
      INTEGER XLOG,YLOG
      XMAX=-1*10E10                                                     
      XMIN=-XMAX                                                        
      YMIN=XMIN
      YMAX=XMAX
%
%   DIMENSION OF PRINTING SURFACE FOR PLOT, ALSO CHANGE SOME
%   FORMAT STATEMENTS
%                                                         
      NXDIM=61
      NYDIM=19
%                                                                       
%   FIND EXTREMAS                                                       
%                                                                       
      DO 1 I=1,N2                                                       
      IF(X2(I) > XMAX) XMAX=X2(I)                                      
      IF(Y2(I) > YMAX) YMAX=Y2(I)                                      
      IF(X2(I) < XMIN) XMIN=X2(I)                                      
      IF(Y2(I) < YMIN) YMIN=Y2(I)                                      
%
%   blank array
%
 1    CONTINUE                                                          
      DO 29 I=1,NXDIM
      DO 29 K=1,NYDIM
      A(I,K)=' '
 29   CONTINUE                                                          
%                                                                       
%   PUT IN GRID                                                         
%                                                                       
       DO 50 I=nydim-4,1,-5                                                   
       DO 50 K=1,nxdim,2                                                   
       A(K,I)='.'                                                        
  50   CONTINUE                                                          
       DO 51 K=1,nxdim,10                                                  
       DO 51 I=1,nydim,2                                                    
       A(K,I)='.'                                                        
  51   CONTINUE                                                          
%                                                                       
%   SCALING                                                             
%                                                                       
%                                                                       
%   ENSURE THAT VERTICAL AND HORIZONTAL LINES CAN BE PLOTTED            
%                                                                       
      XMM=XMAX-XMIN                                                     
      YMM=YMAX-YMIN                                                     
      if(XMM == 0.0), XMIN=XMIN-1.0; end                                      
      if(YMM == 0.0), YMIN=YMIN-1.0; end                                     
      XR=(NXDIM-1)/(XMAX-XMIN)                                              
      YR=(NYDIM-1)/(YMAX-YMIN)                                               
      if(XMM == 0.0), XR=XR/2.0; end                                          
      if(YMM == 0.0), YR=YR/2.0; end                                          
%                                                                       
%   A-VALUES FOR X2-Y2 VARIABLES                                        
%                                                                       
      DO 12 I=1,N2                                                      
      IX=(X2(I)-XMIN)*XR+1.5                                            
      IY=(Y2(I)-YMIN)*YR+1.5                                            
      IY=NYDIM+1-IY                                                                                                     
      A(IX,IY)='+'
 12   CONTINUE                                                          
%                                                                       
%   X1 VARIABLES, REMOVE THE ONES OUTSIDE THE GRID                      
%                                                                       
      if(N1 == 0), GO TO 5; end                                              
      DO 2 I=1,N1                                                       
         NX=(X1(I)-XMIN)*XR+1.5                                            
         if(NX > NXDIM | NX < 1), GO TO 11; end                                
         NY=(Y1(I)-YMIN)*YR+1.5                                            
         NY=NYDIM+1-NY                                                          
         if(NY > NYDIM | NY < 1), GO TO 11; end                                  
         A(NX,NY)='O'
 11      CONTINUE                                                          
 2    CONTINUE 
%                                                         
 5    CONTINUE                                                          

%                                                                       
%   VALUES AT AXIS DIVISIONS                                            
%                                                                       
      DO 10 I=1,NYDIM
      YSC(NYDIM+1-I)=YMIN+(I-1)/YR                                           
 10   CONTINUE                                                          
      DO 15 I=1,NXDIM/10+1                                                      
      XSC(I)=XMIN+(I-1)*10.0/XR                                         
 15   CONTINUE                                                          
%                                                                       
%   PRINTING                                                            
%                                                                       
      WRITE(6,100) YTEXT                                                      
 100  FORMAT(2X,A8,2X,63('-'),5X)                               
 101  FORMAT(12X,63('-'),5X)                               
      for 20 IL=1:NYDIM                                                 
      IF(YLOG == 1)
         WRITE(6,201)10**YSC(IL),(A(I,IL),I=1,NXDIM)                     
         else
         WRITE(6,201)YSC(IL),(A(I,IL),I=1,NXDIM)                     
      end
 201  FORMAT(1X,G10.3,1X,'I',61A1,'I')                            
 20   CONTINUE                                                          
      WRITE(6,101)
      if(XLOG == 1)                                                      
      WRITE(6,202) XTEXT,(10**XSC(I),I=1,NXDIM/10+1)
      else
      WRITE(6,202) XTEXT,(XSC(I),I=1,NXDIM/10+1)
      end
      202  FORMAT(2X,A6,11(F8.2,2X))
      RETURN
         end
      %
      %
      subroutine read_poles
      %
      %   read poles and zeros
      %
      implicit none
      %
      real ppr(1000),ppi(1000)   ! poles,  real and im.
      real pzr(1000),pzi(1000)   ! zeros, real and im.
      complex pol(500),zero(500)  ! complex poles and zeros
      integer npol,nzero        ! number of poles and zeros
      real norm                 ! normalization constant for poles and zeros
      INTEGER I
      %
      common /resp/npol,nzero,ppr,ppi,pzr,pzi,pol,zero,norm
      %
      %   read response values
      %
      read(20,*) npol,nzero,norm
      if(npol > 0)
          for i=1:npol
          read(20,*) ppr(i),ppi(i)
          end
      end
          if(nzero > 0)
              for i=1:nzero
              read(20,*) pzr(i),pzi(i)
              end
          end
              %         write(6,*)npol,nzero,norm
              %
              %   convert to complex
              %
              for i=1:npol
              pol(i)=cmplx(ppr(i),ppi(i))
              end
              for i=1:nzero
              zero(i)=complex(pzr(i),pzi(i))
              end
              return
          end
          
          character*1 function sym_fir(nfir,fir)
          implicit none
          double precision fir(*)
          integer nfir,i
          logical even
          logical sym
          
          if (mod(nfir,2) == 0)
              even=true
          else
              even=false
          end
              sym=true
              for i=1:int(nfir/2)
              if (abs(fir(i)-fir(nfir-i+1)) > abs(0.01*fir(i)))
                  sym=.false.
              end
              end
                  if (.not.sym)
                      sym_fir='A'
                  elseif (even)
                      sym_fir='%'
                  else
                      sym_fir='B'
                  end
                      
                      %
                      % for the case of symmetric filters, only half the coeffs are stored
                      %
                      if (sym_fir == 'B') nfir=(nfir+1)/2
                          if (sym_fir == 'C') nfir=nfir/2
                              
                              return
                          end
                          
                          real function delay_fir(nfir,rate)
                          %
                          % compute fir filter delay
                          %
                          implicit none
                          integer nfir
                          real rate,delay
                          
                          if (mod(nfir,2) == 0)
                              delay=float(nfir)/2.*1./rate
                          else
                              delay=float(nfir-1)/2.*1./rate
                          end
                              delay_fir=delay
                              return
                          end
                          
                          real function normalize_fir(nfir,fir,rate)
                          implicit none
                          double precision fir(*)
                          real rate,pi,f0,x,y,dt
                          integer nfir
                          integer a
                          parameter (pi=3.141592654)
                          complex hc(10000),resp,i
                          
                          f0=1.
                          dt=1./rate
                          %      write(*,*) ' sample interval ',dt,nfir
                          i=(0,1)
                          %
                          % normalize FIR filter
                          %
                          resp=(0,0)
                          for a=1:nfir
                              resp=resp+fir(a)*exp(2.*pi*i*f0*dt)
                          end
                          normalize_fir=1./cabs(resp)
                          %      write(*,*) cabs(resp)
                          %      do a=1,nfir
                          %        x=fir(a)*cos(2.*pi*f0*dt*float(a))
                          %        y=-1.*fir(a)*sin(2.*pi*f0*dt*float(a))
                          %        x=fir(a)*cos(2.*pi*f0*dt)
                          %        y=-1.*fir(a)*sin(2.*pi*f0*dt)
                          %        hc(a)=x+y*i
                          %      enddo
                          %      resp=(0,0)
                          %      do a=1,nfir
                          %        resp=resp+hc(a)
                          %      enddo
                          %      write(*,*) cabs(resp)
                          return
                      end
                      
                      
                  end
                  
                  
              end
%}