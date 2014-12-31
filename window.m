%--------------------- Window function -------------------------------------------  
function w = window(N,wt,beta)
%
%  w = window(N,wt)
%
%  generate a window function
%
%  N = length of desired window
%  wt = window type desired
%       'rect' = rectangular        'tria' = triangular (Bartlett)
%       'hann' = Hanning            'hamm'  = Hamming
%       'blac' = Blackman
%		  'kais' = Kaiser	
%
%  w = row vector containing samples of the desired window
% beta : used in Kaiser window

nn = N-1;
n=0:nn;
pn = 2*pi*(0:nn)/nn;
if wt(1,1:4) == 'rect',
    w = ones(1,N);
elseif wt(1,1:4) == 'tria',
    m = nn/2;
    w = (0:m)/m;
    w = [w w(ceil(m):-1:1)];
elseif wt(1,1:4) == 'hann',
    w = 0.5*(1 - cos(pn));
elseif wt(1,1:4) == 'hamm',
    w = .54 - .46*cos(pn);
elseif wt(1,1:4) == 'blac',
    w = .42 -.5*cos(pn) + .08*cos(2*pn);
elseif wt(1,1:4) == 'kais',
    if nargin<3
        error('you need provide beta!')
    end
    w =bessel1(beta*sqrt(1-((n-N/2)/(N/2)).^2))./bessel1(beta);   
else
    disp('Incorrect Window type requested')
end