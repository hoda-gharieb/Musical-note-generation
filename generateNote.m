%generate the ABC note
function [ Oct, Keys, notes ] = generateNote( x )
notes = '';
Nn = '--';
num = 0;
index = 1;
Keys = zeros(100, 1);
Oct = '--';
for i = 1 : 1 : size(x)
    N = cellstr( note( x(i)) );
    if( strcmp(Nn,N) == 0 && strcmp(Nn,'--') == 0 )
    notes = strcat( notes , N);
    notes = strcat( notes ,  ' - ' );
    Nn = N;
    Keys( index ) = num;
    Oct = char( Oct, char(N));
    num = 0;
    index = index + 1;
    elseif ( strcmp(Nn,N) == 0 )
      Nn = N;  
    else
          num = num + 1; 
    end
       
end