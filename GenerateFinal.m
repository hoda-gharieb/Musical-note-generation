function FinalNote = GenerateFinal( Keys,Oct )

FinalNote = '';
for i = 1 : size(Keys,1)
    if( Keys(i,1) >= 10 )
    FinalNote = strcat( FinalNote , Oct(i+1, : ));
    FinalNote = strcat( FinalNote ,  ' - ' );
    end
end
end

