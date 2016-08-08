function respons = inter_p( nresp, normtab, freq_val, gain_val, phas_val, f)
% INTER_P Interpolation of response values
% RESP Calculates instrument response based on a number of inputs
% This program has been translated from SEISAN 10.4.1
% Genius belongs to the creators of SEISAN. Mistakes are mine.
% Translator: Jay Wellik (June 2016)
% Original Author: J. Havskov (Feb 1997)
%
% INPUT
% + nresp       - number of values in
% + normtab 	- value to multiply with
% + freq_val,gain_val,phas_val - frequency, amplitude and phase in
% + f       	- frequency for desired output
%
% OUTPUT
% + response	- interpolated response value at frequency f
%
%

%% Original code
%{
subroutine inter_p(nresp,normtab,
     *freq_val,gain_val,phas_val,f,respons)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   interpolation of response values
c
c      nresp   : number of values in
c      normtab : value to multiply with
c      freq_val,gain_val,phas_val : frequency, amplitude and phase in

c      f       : frequency for desired output
c      response: interpolated response value at frequency f
c
c
c    J. Havskov, feb 97
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
      real normtab   ! multiplying factor
c   individul response values
      real freq_val(*),gain_val(*),phas_val(*)
      INTEGER J
c-- frequency
      real              f
      integer nresp
      complex           respons
c-- gain and phase at f
      real              gainf,phasf
c           
c   do linear interpolation, first find which 2 frequencies to use
c           
      do j=1,nresp-1
         if(freq_val(j+1).eq.0.0) go to 1       ! no more response values
         if(f.ge.freq_val(j).and.f.le.freq_val(j+1)) go to 1
      enddo 

 1    continue
      gainf=gain_val(j)+(f-freq_val(j))*(gain_val(j+1)-gain_val(j))/
     *(freq_val(j+1)-freq_val(j))
      phasf=phas_val(j)+(f-freq_val(j))*(phas_val(j+1)-phas_val(j))/
     *(freq_val(j+1)-freq_val(j))

c      if(freq_val(j+1).eq.0.0.or.j.eq.nresp-1)
c     *write(6,*)' response suspicious'

c           
c   calculate complex response value
c

      respons=normtab*gainf*cmplx(cos(phasf/57.3),sin(phasf/57.3))
      return
      end
%}

%%

         
% do linear interpolation, first find which 2 frequencies to use    
for j=1:nresp-1
    if(freq_val(j+1)==0.0), break; end % no more response values
    if(f >= freq_val(j) && f <= freq_val(j+1)), break; end
end

gainf = gain_val(j)+(f-freq_val(j))*(gain_val(j+1)-gain_val(j))/ ...
     (freq_val(j+1)-freq_val(j));
phasf = phas_val(j)+(f-freq_val(j))*(phas_val(j+1)-phas_val(j))/ ...
     (freq_val(j+1)-freq_val(j));
        
% calculate complex response value
respons = normtab * gainf*complex(cos(phasf/57.3),sin(phasf/57.3));

      
end         