%*****************************************************************************************
%-------------- compute subharmonic-to-harmonic ratio  ---------------------------------
%*****************************************************************************************
function [peak_index,SHR,shshift,index]=ComputeSHR(log_spectrum,min_bin,startpos,endpos,lowerbound,upperbound,N,shift_units,SHR_Threshold)
% computeshr: compute subharmonic-to-harmonic ratio for a short-term signal
len_spectrum=length(log_spectrum);
totallen=shift_units+len_spectrum;
shshift=zeros(N,totallen); %initialize the subharmonic shift matrix; each row corresponds to a shift version
shshift(1,(totallen-len_spectrum+1):totallen)=log_spectrum; % place the spectrum at the right end of the first row
% note that here startpos and endpos has N-1 rows, so we start from 2
% the first row in shshift is the original log spectrum
for i=2:N
    shshift(i,startpos(i-1):endpos(i-1))=log_spectrum(1:endpos(i-1)-startpos(i-1)+1); % store each shifted sequence
end
shshift=shshift(:,shift_units+1:totallen); % we don't need the stuff smaller than shift_units
%for odd we sum log( 0.5nf0 ) for n = 1, 3, 5 .... 
shsodd=sum(shshift(1:2:N-1,:),1); 
%for odd we sum log( 0.5nf0 ) for n = 2, 4, 6 .... 
shseven=sum(shshift(2:2:N,:),1);

difference=shseven-shsodd;
% peak picking process
SHR=0;
[mag,index]=twomax(difference,lowerbound,upperbound,min_bin); % only find two maxima
% first mag is always the maximum, the second, if there is, is the second max
NumPitchCandidates=length(mag);
if (NumPitchCandidates == 1) % this is possible, mainly due to we put a constraint on search region, i.e., f0 range
    if (mag <=0) % this must be an unvoiced frame
        peak_index=-1;
        return
    end
    peak_index=index;
    SHR=0;
else
    SHR=(mag(1)-mag(2))/(mag(1)+mag(2));
    if (SHR<=SHR_Threshold) 
        peak_index=index(2);  % subharmonic is weak, so favor the harmonic
    else
        peak_index=index(1); % subharmonic is strong, so favor the subharmonic as F0
    end
end