%maps a midi number to its corresponding ABC notation
function voices = note(num)

sym = [' C';'C#';' D';'D#';' E';' F';'F#';' G';'G#';' A';'A#';' B'];
 num = num - 23;
 y = 1;
 while( num > 12 )
     num = num - 12;
     y = y+1;
 end
 voices = [sym(num,:),char(transpose(48+y))];
