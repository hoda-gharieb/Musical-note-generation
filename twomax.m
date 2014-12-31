%%*****************************************************************************************
%******************    this function only finds two maximum peaks   ************************
function [mag,index]=twomax(x,lowerbound,upperbound,unitlen)
%In descending order, the magnitude and index are returned in [mag,index], respectively
lenx=length(x);
halfoct=round(1/unitlen/2); % compute the number of units of half octave. log2(2)=1; 1/unitlen
[mag,index]=max(x(lowerbound:upperbound));%find the maximum value
if (mag<=0)
    %    error('max is smaller than zero!') % return it!
    return
end
index=index+lowerbound-1;
harmonics=2;
LIMIT=0.0625; % 1/8 octave
startpos=index+round(log2(harmonics-LIMIT)/unitlen);
if (startpos<=min(lenx,upperbound))
    endpos=index+round(log2(harmonics+LIMIT)/unitlen); % for example, 100hz-200hz is one octave, 200hz-250hz is 1/4octave
    if (endpos> min(lenx,upperbound))
        endpos=min(lenx,upperbound);
    end
    [mag1,index1]=max(x(startpos:endpos));%find the maximum value at right side of last maximum 
    if (mag1>0)
        index1=index1+startpos-1;
        mag=[mag;mag1];
        index=[index;index1];
    end
end