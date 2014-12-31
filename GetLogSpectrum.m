%*****************************************************************************************
%-------------- do FFT and get log spectrum  ---------------------------------
%*****************************************************************************************
function [interp_amplitude]=GetLogSpectrum(segment,fftlen,limit,logf,interp_logf)
Spectra=fft(segment,fftlen);
amplitude = abs(Spectra(1:fftlen/2+1)); % fftlen is always even here. Note: change fftlen/2 to fftlen/2+1. bug fixed due to Herbert Griebel
amplitude=amplitude(2:limit+1); % ignore the zero frequency component
%amplitude=log10(amplitude+1);
interp_amplitude=interp1(logf,amplitude,interp_logf,'linear');
interp_amplitude=interp_amplitude-min(interp_amplitude);