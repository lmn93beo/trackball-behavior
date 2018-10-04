 function  [MissMatch, MovIndex] = GenerateSequence( Num_of_Movies, BlankDuration , SessionDuration )

if nargin < 3; SessionDuration = 600; end;
if nargin < 2; BlankDuration   = 4;   end;
if nargin < 1; Num_of_Movies   = 9;   end;

if Num_of_Movies > 12; error('Number of Movies in database exceeded! Max. allowed number = 12'); end;

% generate initial sequence based on the number of movies.................
NumMovies = Num_of_Movies;
MovSeq    = 1:NumMovies;

% get timing information..................................................
Dur_Each_mov = 4; % in seconds
Dur_Blank    = BlankDuration;% in seconds
Dur_Session = SessionDuration; % in seconds
Total_Dur_Sequence = (NumMovies.*Dur_Each_mov) + Dur_Blank;

% generate number of reps required.........................................
Reps = Dur_Session./Total_Dur_Sequence;

% generate results matrix .................................................
for i = 1: fix(Reps)
    MovIndex(i,:) = MovSeq;
end;

MissMatch = Dur_Session - fix(Reps)*Total_Dur_Sequence;





