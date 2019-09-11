 function N = GenerateCombinations_RVR

interleave = 0;
NumSpatFreq = 1;
rabiesGcamp = 0;


pixelperdegree = 14.22;
Dsf=[0.02,0.04,0.08,0.16,0.32];%% cycles/degree
% Dsf(1:8) = 0.18;
%SpatInc = Dsf/pixelperdegree;%cycles/pixel
SpatInc = 0.32/pixelperdegree;



if ~interleave && ~rabiesGcamp
	NumOrient   = 16 ;
	Angles  = linspace(0, 337.5, NumOrient);
	% SpatInc =  [0.002*2.^(1:NumSpatFreq)];
elseif interleave
	NumOrient = 17;
	Angles = linspace(0, 360, NumOrient);
elseif rabiesGcamp
    NumOrient = 12;
    Angles = linspace(0, 330, NumOrient);
end 
	
B       = repmat(SpatInc, 1, NumOrient )';
A       = repmat(Angles,NumSpatFreq,1);

Combs = zeros(NumSpatFreq*NumOrient,2);
Combs(:,2) = B;

for i = 1:1:NumOrient
    foo = A(:,i);
    Combs( 1 + NumSpatFreq*(i-1) : i*NumSpatFreq) = foo;
end;

N = [];

if ~interleave && ~rabiesGcamp
	for i = 1:10
        N = [N; Combs];
    end
elseif ~interleave 
    for i = 1:10
		N = [N; Combs(randperm(size(Combs,1)),:) ];
    end
else
	for i = 1:5
		preN = Combs(randperm(size(Combs,1)),:);
		N = [N; repmat(preN,2,1)];
	end
	 
end
 end