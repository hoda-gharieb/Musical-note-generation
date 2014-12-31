% applying the equation that transforms the frequency to a midi number
SHR2 = 69 + ( 12 .* log2( f0candidates(:,2)/440 ) );
% getting int value from the array
SHR2 = abs(SHR2);
SHR2 = uint32(SHR2);
% getting the notes that are > 23 as we start our octave from C1
IndMax = find( SHR2 < 4294967295  );
X = zeros( size(IndMax), 1 );
for i = 1 : size(IndMax)
    X(i,1) = SHR2( IndMax(i,1), 1 ) ;
end