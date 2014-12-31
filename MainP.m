[Y,Fs,nBits,wavInfo] = wavread('H:\dsp\twinkle.wav');
[f0time,f0value,SHR,f0candidates]=shrp(Y,Fs);
Pitches;
[Oct, Keys,notes] = generateNote( X );
dlmwrite('H:\twinkle.txt',notes(1,1),'delimiter','');
FinalNote = GenerateFinal( Keys, Oct );
dlmwrite('H:\FinalTwinkle.txt',FinalNote(1,:),'delimiter','');
