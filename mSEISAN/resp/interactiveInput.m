function USERINPUT = interactiveInput
% RESPUSERINPUT Prompts user for input to be used in RESP module
%
% see also RESP

%% INITIALIZE VALUES (Default Values)

npol=0;
nzero=0;
norm=1.;
USERINPUT.outtyp = NaN;
USERINPUT.gse_cal2_instype = ' ';
USERINPUT.SENTYP = NaN;
USERINPUT.PERIOD=0.;
USERINPUT.DAMPIN=0.;
USERINPUT.GENCON=0.;
USERINPUT.GAIN=0; % doesn't the prompt say that the default value is 1?
USERINPUT.REGAIN=1;
USERINPUT.GSEPAZSCALE=1.;
USERINPUT.gse_dig2_description = ' ';
USERINPUT.gse_dig2_samprat=0.;
USERINPUT.gse_dig2_sensitivity=1.;
USERINPUT.NFILT = 0;
USERINPUT.FFILT = NaN;
USERINPUT.POLE = NaN;
USERINPUT.RESTYP = 1;
USERINPUT.RESCOR = 0;
amp1hz=0.;

%%

paz = false;
gse = false;

% OPENING DISPLAY
fprintf(' RESP - PROGRAM TO CREATE RESPONSE FILES IN SEISAN\n');
fprintf('        OR GSE FORMAT. THE RESPONSE CAN BE CREATED\n');
fprintf('        AS POLES AND ZEROS (PAZ) OR FREQUENCY\n');
fprintf('        AMPLITUDE AND PHASE (FAP). THE SAME\n');
fprintf('        TRANSFER FUNCTION AND FILTERS ARE USED\n');
fprintf('        IN BOTH CASES.\n');
fprintf('\n');

% ENTER OUTPUT FORMAT
fprintf(' CHOSE OUTPUT FORMAT: 0: NO OUTPUT FILE \n');
fprintf('                      1: SEISAN FAP \n');
fprintf('                      2: SEISAN PAZ \n');
fprintf('                      3: GSE2 FAP \n');
fprintf('                      4: GSE2 PAZ \n');
outtyp = input('');
if(outtyp == 3 || outtyp == 4), gse=true; end
if(outtyp == 2 || outtyp == 4), paz=true; end
USERINPUT.outtyp = outtyp;

% ENTER INPUT PARAMETERS FROM KEYBOARD
fprintf(' TYPE OF SENSOR:       1: NONE \n');
fprintf('                       2: SEISMOMETER \n');
fprintf('                       3: ACCELEROMETER \n');
fprintf('                       4: MECHANICAL DISPLACEMENT SEISMOMETER \n');  
SENTYP = input('');
USERINPUT.SENTYP = SENTYP;

% SENSOR PARAMETERS
GENCON=1;
if(SENTYP == 2 || SENTYP == 4)
    PERIOD = input(' SEISMOMETER NATURAL PERIOD ? \n');
    DAMPIN = input(' SEISMOMETER DAMPING RATIO ? \n');
end

if SENTYP == 2 || SENTYP == 3
    GENCON = input(' SENSOR LOADED GENERATOR CONSTANT (V/M/S OR V/G) ? \n');
end
USERINPUT.PERIOD = PERIOD;
USERINPUT.DAMPIN = DAMPIN;
USERINPUT.GENCON = GENCON;

% INSTRUMENT TYPE IF GSE ONLY
% gse_cal2_instype=' ';
if (gse && SENTYP ~= 1)
    fprintf('  INSTRUMENT TYPE FROM LIST BELOW (<6 CHARS)\n');
    fprintf('  e.g., Akashi, 23900, BB-13V, CMG-3, CMG-3N, CMG-3T, CMG-3E, \n');
    fprintf('  FBA-23, GS-13, GS-21, KS3600, KS360i, KS5400, MK II, \n');
    fprintf('  Oki, Parus2, S-13, S-500, STS-1, STS-2, TSJ-1e \n');
    fprintf(' CHOICE (OR TYPE YOUR OWN ANSWER) \n');
    gse_cal2_instype = upper(input('', 's'));
end
USERINPUT.gse_cal2_instype = gse_cal2_instype;

% RECORDING MEDIA GAIN
txt = input(' RECORDING MEDIA GAIN (COUNT/V, M/V OR TIMES), enter for 1.0 ? \n');
if ~isempty(txt)
    USERINPUT.REGAIN = txt;
end


if (gse)
    txt = input(' DIGITIZER SAMPLE RATE \n (BEFORE POSSIBLE FIR FILTER) \n');
    if ~isempty(txt)
        USERINPUT.gse_dig2_samprat=txt;
%     else
%         gse_dig2_samprat = 0;
    end
    USERINPUT.gse_rate = USERINPUT.gse_dig2_samprat;
    USERINPUT.gse_dig2_description = upper(input(' DIGITIZER MODEL \n', 's'));
    
end


%   AMPLIFIER PARAMETERS
txt = input(' AMPLIFIER GAIN (DB), ENTER FOR 0 DB (GAIN 1.0) ? \n');
if ~isempty(txt)
    USERINPUT.GAIN = txt;
end

      
% Number of filters
% NFILT = 0;
txt = input(' NUMBER OF FILTERS (0-10), RETURN FOR NONE ? \n');
if ~isempty(txt)
    USERINPUT.NFILT = txt;
end

% USERINPUT.FFILT = [];
% USERINPUT.POLE = [];
if USERINPUT.NFILT > 0
    fprintf(' FREQUENCY AND NUMBER OF POLES FOR EACH FILTER, \n POLES NEGATIVE FOR HIGH PASS \n');
    for I = 1:USERINPUT.NFILT
        txt = input('', 's');
        nnum = str2num(txt);
        USERINPUT.FFILT(I) = nnum(1); USERINPUT.POLE(I) = nnum(2);
        if numel(nnum)~=2, warning('Incorrect syntax for filter input'); end
    end
% USERINPUT.FFILT = FFILT;
% USERINPUT.POLE = POLE;    
end


% TYPE OF RESPONSE IF SENSOR IS USED
% USERINPUT.RESTYP=1;
% USERINPUT.RESCOR=0;
if SENTYP > 1
    if ~paz
        
        fprintf(' TYPE OF RESPONSE: 1: DISPLACEMENT\n')
        fprintf('                   2: VELOCITY\n')
        fprintf('                   3: ACCELERATION\n')
        fprintf(' NOTE: CHOOSE DISPLACEMENT IF YOU ARE CREATING SEISAN RESPONSE FILE\n')
        USERINPUT.RESTYP = input('', 's');
      
        % Calculate Exponent for Response Type Correction
        
        if(SENTYP==2), USERINPUT.RESCOR=USERINPUT.RESTYP-1; end
        if(SENTYP==3), USERINPUT.RESCOR=USERINPUT.RESTYP-3; end
        if(SENTYP==4), USERINPUT.RESCOR=USERINPUT.RESTYP; end
    end
end

      
      %{
c
c   file name of file with poles and zeros or tabulated values,
c   can multiply with
c   existing curve or use alone
c
         nresp=0
         goto 544
 444     CONTINUE
         write(6,*)' No such file'
 544     continue
         WRITE(6,*) ' FILE NAME FOR FILE WITH POLES AND ZEROS ',
     *   'FOR SEISMOMETER, RETURN FOR NO FILE'
         READ(5,'(A)') FILEPOLE
         IF(FILEPOLE(1:2).NE.'    ') THEN
            OPEN(20,FILE=FILEPOLE,STATUS='OLD',ERR=444)
            CALL READ_POLES                 ! read poles and zeros
            write(6,*)' ',npol+nzero,' poles and zeros'
            close(20)
         endif
         if (gse.and.sentyp.lt.2) then
           if (npol+nzero.eq.0) then
             write(*,*) ' for GSE output: instrument or paz '//
     &        'have to be given, forced EXIT '
             stop
           endif
         endif

c
c   tabulated values
c
         goto 545
 445     CONTINUE
         write(6,*) 'No such file'
 545     continue
         FILETAB = '  '
         if (.not.paz) then
           WRITE(6,*) ' FILE NAME FOR TABULATED VALUES,',
     *       ' RETURN FOR NO FILE'
           READ(5,'(A)') FILETAB
         endif
         IF(FILETAB(1:2).NE.'    ') THEN
            OPEN(20,FILE=FILETAB,STATUS='OLD',ERR=445)
            read(20,*) nresp,normtab
            write(6,*) ' ',nresp,' tabulated values'
            do i=1,nresp                    ! read tabulated values
               read(20,*) freq_val(i),gain_val(i),phas_val(i)
            enddo
            close(20)
         endif

c
c FIR FILTERS IF FORMAT IS GSE
c
      nfirstage=0
      if (gse) then
        write(*,*) ' NUMBER OF FIR FILTER STAGES '
        READ(5,'(a)') TEXT
        IF(TEXT(1:2).EQ.'  ') THEN
          nfirstage=0
        ELSE
          CALL SEI GET VALUES(1,TEXT,CODE)
          nfirstage=ARRAY$(1)
        ENDIF
c        read(5,*) nfirstage
        do i=1,nfirstage
          goto 546
 446      CONTINUE
          write(6,*) 'No such file'
 546      continue
          FILEFIR = '  '
          WRITE(6,*) ' FILE NAME FOR FIR COEFFICIENTS,',
     *        ' RETURN FOR NO FILE'
          READ(5,'(A)') FILEFIR
          write(*,*) ' DECIMATION, FIR STAGE ',i
          read(5,*) fir_deci(i)
          write(*,*) ' FIR FILTER SYMMETRY (A=asymetric, ' //
     &               'B=symetric (odd) '//
     &               'C=symetric (even) '
          read(5,*) fir_sym(i)
          IF(FILEFIR(1:2).NE.'    ') THEN
             OPEN(20,FILE=FILEFIR,STATUS='OLD',ERR=446)
               nfir(i)=0
               fir_sum(i)=0.
 547           CONTINUE
               read(20,*,end=548) xl
               nfir(i)=nfir(i)+1
               fir(i,nfir(i))=xl
               fir_sum(i)=fir_sum(i)+xl
c               write(55,*) nfir(i),xl
               GOTO 547
 548           CONTINUE
             close(20)
             if (fir_sym(i).eq.'B') then
               do k=1,nfir(i)-1
                 fir_sum(i)=fir_sum(i)+fir(i,k)
               enddo
             elseif (fir_sym(i).eq.'C') then
               do k=1,nfir(i)
                 fir_sum(i)=fir_sum(i)+fir(i,k)
               enddo
             endif

c
c normalise
c
             do k=1,nfir(i)
               fir(i,k)=fir(i,k)/fir_sum(i)
             enddo
             write(*,*) ' stage ',i,
     &           ' number of fir coefficients ',nfir(i)
          endif
c          write(*,*) ' SAMPLE RATE AT INPUT TO FIR FILTER, '
c     &     //'FIR STAGE ',i
c          read(5,*) fir_rate(i)
          if (i.eq.1) then
            fir_rate(i)=gse_dig2_samprat
          else
            fir_rate(i)=fir_rate(i-1)/fir_deci(i-1)
          endif
          write(*,*) ' input sample rate ',fir_rate(i)
          write(*,*) ' output sample rate ',fir_rate(i)/fir_deci(i)
          if (i.eq.nfirstage) gse_rate=fir_rate(i)/fir_deci(i)
        enddo
      endif
%}



end