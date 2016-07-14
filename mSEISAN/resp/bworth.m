function hs = bworth(f, fo, np)
% BWORTH Calculates the response of a np pole butterworth filter up to as
% many poles as the arrays s and t are dimensioned
%
% INPUT
% + f   - frequency(hz)                                                            
% + fo  - the corner frequency of the filter                                      
% + np  - the number of poles, negative for high pass                             
%
% OUTPUT
% + hs  - complex response of the filter  
%

%% Original Code
%{
      subroutine bworth(f,fo,np,hs)                                             
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc   
ccccc                                                                           
c    bworth cal the response of a np pole butterworth filter up to              
c    as many poles as the arrays s and t are dimensioned                        
c                                                                               
c    f-frequency(hz)                                                            
c    fo-the corner frequency of the filter                                      
c    np-the number of poles, negative for high pass                             
c    hs-complex response of the filter                                          
c                                                                               
c    the formula used -- h(s)=1/(s-s1)(s-s2)...(s-sk)                           
c                        i*pi*(1/2+((2*k-1)/(2*np)))                            
c    where         sk=exp                                                       
c                                   k=1,2, ... np                               
c                  s = i(f/fo)                                                  
c                                                                               
c    ref theory and application of digital signal processing                    
c    rabiner and gold page 227 prentice-hall 1975                               
c                                                                               
c    Adapted to Vax/VMS by R. A. Hansen                                         
c                                                                               
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc   
ccccc                                                                           
c                                                                               
      complex s(20),t(20),as,bk,hs                                              
      hs=cmplx(1.0,0.0)                                                         
      n=iabs(np)                                                                
      if(np .eq. 0) go to 6                                                     
      if(f .eq. 0.0 .and. np .lt. 0) hs=cmplx(0.0,0.0)                          
      if(f .eq. 0.0 .and. np .lt. 0) go to 6                                    
      do 1 k=1,n                                                                
      an=float(k)                                                               
      ak=3.141592654*(0.5+(((2.*an)-1.)/(2.*float(n))))                         
      bk=cmplx(0.0,ak)                                                          
 1    s(k)=cexp(bk)                                                             
      ss=f/fo                                                                   
      as=cmplx(0.0,ss)                                                          
      if(np.lt.0) as=1./as                                                      
      t(1)=as-s(1)                                                              
      if(n.eq.1) go to 5                                                        
      do 2 i=2,n                                                                
 2    t(i)=(as-s(i))*t(i-1)                                                     
 5    continue                                                                  
      hs=1./t(n)                                                                
 6    return                                                                    
      end           
%}

%%

hs=complex(1.0,0.0);
n=abs(np);


% return statements for certian conditions
if(np == 0), return; end;
if(f == 0.0 && np < 0), hs=complex(0.0,0.0); return; end


for k = 1:n % do 1 k=1,n
    an=k;
    ak=pi*(0.5+(((2*an)-1)/(2*n)));
    bk=complex(0.0,ak);
    s(k)=complex(bk);
end
ss=f/fo;
as=complex(0.0,ss);
if(np < 0), as=1/as; end
t(1)=as-s(1);
if(n~=1)
    for i = 2:n % do 2 i=2,n
        t(i)=(as-s(i))*t(i-1);
    end
end
hs=1/t(n);


end