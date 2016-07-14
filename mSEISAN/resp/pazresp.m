function clxrsp = pazresp(freq, pazconstant, numzeros, zers, numpoles, poles)
% PAZRESP Compute response from poles and zeros
% This program has been translated from SEISAN 10.4.1
% Genius belongs to the creators of SEISAN. Mistakes are mine.
% Original Author: Tormod Kvaerna (March 8, 1995)
% % Translator: Jay Wellik (June 2016)
%
% INPUT
% + freq        - Frequency (Hz)
% + pazconstant - Constant in paz representation
% + numzeros    - Number of zeros
% + zers        - Complex zeros
% + numpoles    - Number of poles
% + poles       - Complex poles
%
% OUTPUT
% + clxrsp      - Complex amplitude in counts/m%
%
% USAGE
%
%

%% Original Header, Comments, and Internatl Declarations
%{
%       subroutine pazresp (freq, pazconstant, numzeros, zeros,
%      $     numpoles, poles,  clxrsp)
      implicit none
      complex zeros(*), poles(*), clxrsp
      real     freq, pazconstant
      integer    numzeros, numpoles


c.======================================================================
c.    Purpose                                                           
c     Compute_response_from_poles_and_zeros                       resp<<
c.----------------------------------------------------------------------
c.    Keywords                                                          
c.----------------------------------------------------------------------
c.    Package                                                           
c.    Visible                                                           
c.    Standard_fortran_77                                               
c.    Use_only                                                          
c.----------------------------------------------------------------------
c.    Input                                                             
c     
c..   freq        - Frequency (Hz)
c..   pazconstant - Constant in paz representation
c..   numzeros    - Number of zeros
c..   zeros       - Complex zeros
c..   numpoles    - Number of poles
c..   poles       - Complex poles
c
c.    Output
c
c..   clxrsp     - Complex amplitude in counts/m
c     
c.----------------------------------------------------------------------
c.    Programmer    Tormod Kvaerna                                     
c.    Creation_date 080395
c.    Made_at  
c     NORSAR
c     Granaveien 33
c     N-2007 Kjeller
c     
c.    Modification
c.    dec 17, 95 : simplification, use single precision
c.    Correction                                                        
c.======================================================================


%c----
%c     Internal declarations
%c----
%       complex*16      s, tzero, tpole
%       real            pi, omega
%       integer         i

%       pi   = 3.141592654d0

%}

%% Poles and Zeros Response
% original code
%{
%c----
%c     Poles and zeros response
%c----
%       omega = 2.0*pi*freq;
%       s     = cmplx(0.0, omega);
%       tzero = (1.0,0.0);
%       tpole = (1.0,0.0);
%       do 1000 i = 1, numzeros
%          tzero = tzero*(s-zers(i))
%  1000 continue
%       do 2000 i = 1, numpoles
%          tpole = tpole*(s-poles(i))
%  2000 continue
% 
%       clxrsp    = cmplx(pazconstant,0.0)*tzero/tpole
% 
%       return
% 
% end
%}

omega = 2.0*pi*freq;
s = complex(0.0, omega);
tzero = [1.0, 0.0];
tpole = [1.0, 0.0];
for i = 1:numzeros
   tzero = tzero * (s-zers(i));     
end
for i = 1:numpoles
   tpole = tpole*(s-poles(i)); 
end
clxrsp = complex(pazconstant, 0.0) * tzero/tpole;


end