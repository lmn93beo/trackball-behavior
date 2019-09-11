function OptBlk = OptimizeMissMatchTime(maxBlank, NumMovies, SessionDur)

bvec = 1:maxBlank;

for m = NumMovies
    ct = 0;
    for b = bvec
        ct = ct+1;
        [MissMatch(ct), ~] = GenerateSequence( m, b , SessionDur);
    end;
    [~,indx] = min(MissMatch);
    OptBlk = bvec(indx);
end;