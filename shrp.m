function [f0_time,f0_value,SHR,f0_candidates]=shrp(Y,Fs,F0MinMax,frame_length,timestep,SHR_Threshold,ceiling,med_smooth,CHECK_VOICING)

% === checking the argument recieved from the function call ====%
if nargin<9
    CHECK_VOICING=0;
end
if nargin<8
    med_smooth=0;
end
if nargin<7
    ceiling=1250;
end
if nargin<6
    SHR_Threshold=0.4; % subharmonic to harmonic ratio threshold
end
if nargin<5
    timestep=10;
   %timestep=6.4;
end
if nargin<4
    frame_length=40; % default 40 ms
end
if nargin<3
    minf0=50;
    maxf0=500;
else
    minf0=F0MinMax(1);
    maxf0=F0MinMax(2);
end
if nargin<2
    error('Sampling rate must be supplied!')
end
% ======= end checking =====%


segmentduration=frame_length; 

%------------------- pre-processing input signal -------------------------

Ymean = mean(Y);
Ymean = Ymean(1); % in case it has more than one channel
Y=Y-Ymean; % remove DC component
Y=Y/max(abs(Y));  %normalization
total_len=length(Y);


%------------------ specify some algorithm-specific thresholds -------------------------
interpolation_depth=0.5;  % for FFT length
%--------------- derived thresholds specific to the algorithm -------------------------------


maxlogf=log2(maxf0/2);
minlogf=log2(minf0/2); % the search region to compute SHR is as low as 0.5 minf0.
N=floor(ceiling/minf0); % maximum number harmonics
m=mod(N,2);
N=N-m;
N=N*4; %In fact, in most cases we don't need to multiply N by 4 and get equally good results yet much faster.
% derive how many frames we have based on segment length and timestep.
segmentlen=round(segmentduration*(Fs/1000));
inc=round(timestep*(Fs/1000));
nf = fix((total_len-segmentlen+inc)/inc);
n=(1:nf);
f0_time=((n-1)*timestep+segmentduration/2)'; % anchor time for each frame, the middle point

%------------------ determine FFT length ---------------------
fftlen=1;
while (fftlen < segmentlen * (1 +interpolation_depth)) 
    fftlen =fftlen* 2;
end
%----------------- derive linear and log frequency scale ----------------
frequency=Fs*(1:fftlen/2)/fftlen; % we ignore frequency 0 here since we need to do log transformation later and won't use it anyway.
limit=find(frequency>=ceiling);
limit=limit(1); % only the first is useful
frequency=frequency(1:limit);
logf=log2(frequency);
%% clear some variables to save memory
clear frequency;
min_bin=logf(end)-logf(end-1); % the minimum distance between two points after interpolation
shift=log2(N); % shift distance
shift_units=round(shift/min_bin); %the number of unit on the log x-axis
i=(2:N);
% ------------- the followings are universal for all the frames ---------------%%
startpos=shift_units+1-round(log2(i)/min_bin);  % find out all the start position of each shift
index=find(startpos<1); % find out those positions that are less than 1
startpos(index)=1; % set them to 1 since the array index starts from 1 in matlab
interp_logf=logf(1):min_bin:logf(end);
interp_len=length(interp_logf);% new length of the amplitude spectrum after interpolation
totallen=shift_units+interp_len;
endpos=startpos+interp_len-1; %% note that : totallen=shift_units+interp_len;
index=find(endpos>totallen);
endpos(index)=totallen; % make sure all the end positions not greater than the totoal length of the shift spectrum

newfre=2.^(interp_logf); % the linear Hz scale derived from the interpolated log scale
upperbound=find(interp_logf>=maxlogf); % find out the index of upper bound of search region on the log frequency scale.
upperbound=upperbound(1);% only the first element is useful
lowerbound=find(interp_logf>=minlogf); % find out the index of lower bound of search region on the log frequency scale.
lowerbound=lowerbound(1);

%----------------- segmentation of speech ------------------------------

curpos=round(f0_time/1000*Fs);   % position for each frame in terms of index, not time
frames=toframes(Y,curpos,segmentlen,'hamm');
[nf framelen]=size(frames);
clear Y;
 

%frames=toframes(Y,curpos,segmentlen,'hamm');
[nf framelen]=size(frames);
clear Y;
%----------------- initialize vectors for f0 time, f0 values, and SHR
f0_value=zeros(nf,1);
SHR=zeros(nf,1);
f0_time=f0_time(1:nf);
f0_candidates=zeros(nf,2);
%----------------- voicing determination ----------------------------
if (CHECK_VOICING)
    NoiseFloor=sum(frames(1,:).^2);   
    voicing=vda(frames,segmentduration/1000,NoiseFloor);
else
    voicing=ones(nf,1);
end



%------------------- the main loop -----------------------
curf0=0;
cur_SHR=0;
cur_cand1=0;
cur_cand2=0;
for n=1:nf
    segment=frames(n,:);
    curtime=f0_time(n);
    if voicing(n)==0
        curf0=0;
        cur_SHR=0;
    else
        [log_spectrum]=GetLogSpectrum(segment,fftlen,limit,logf,interp_logf);
        [peak_index,cur_SHR,shshift,all_peak_indices]=ComputeSHR(log_spectrum,min_bin,startpos,endpos,lowerbound,upperbound,N,shift_units,SHR_Threshold);
        if (peak_index==-1) % -1 indicates a possibly unvoiced frame, if CHECK_VOICING, set f0 to 0, otherwise uses previous value
            if (CHECK_VOICING)
                curf0=0;
                cur_cand1=0;
                cur_cand2=0;
            end
            
        else
            curf0=newfre(peak_index)*2;  
            if (curf0>maxf0)
                curf0=curf0/2;
            end
            if (length(all_peak_indices)==1)
            	cur_cand1=0;
            	cur_cand2=newfre(all_peak_indices(1))*2;
            else
            	cur_cand1=newfre(all_peak_indices(1))*2;
            	cur_cand2=newfre(all_peak_indices(2))*2;
            end	
            if (cur_cand1>maxf0)
                cur_cand1=cur_cand1/2;
            end
            if (cur_cand2>maxf0)
                cur_cand2=cur_cand2/2;
            end
            if (CHECK_VOICING)
                voicing(n)=postvda(segment,curf0,Fs);
                if (voicing(n)==0)
                    curf0=0;
                end
            end
        end
    end
    f0_value(n)=curf0;
    SHR(n)=cur_SHR;
    f0_candidates(n,1)=cur_cand1;
    f0_candidates(n,2)=cur_cand2;
    
    %================= For debugging =================%
    DEBUG=0;
    if DEBUG
        figure(9)
        %subplot(5,1,1),plot(segment,'*') 
        %title('windowed waveform segment')
        subplot(2,2,1),plot(interp_logf,log_spectrum,'k*')
        title('(a)')
        grid
        %('spectrum on log frequency scale')
        %grid
        shsodd=sum(shshift(1:2:N-1,:),1); 
        shseven=sum(shshift(2:2:N,:),1);
        difference=shseven-shsodd;
        subplot(2,2,2),plot(interp_logf,shseven,'k*')
        title('(b)')
        %title('even')
        grid
        subplot(2,2,3),plot(interp_logf,shsodd,'k*')
        title('(c)')
        %title('odd')
        grid
        subplot(2,2,4), plot(interp_logf,difference,'k*')
        title('(d)')
        %title('difference (even-odd)')   
        grid
        curtime
        curf0
        cur_SHR
        pause
    end
    %================== end debugging ================%
end
%-------------- post-processing -------------------------------
if (med_smooth > 0)
    f0_value=medsmooth(f0_value,med_smooth);
end