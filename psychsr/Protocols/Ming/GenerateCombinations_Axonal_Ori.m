 function [N, NumOrient] = GenerateCombinations_Axonal;

interleave = 0;
NumSpatFreq = 1;
rabiesGcamp = 0;


if ~interleave & ~rabiesGcamp
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
	
SpatInc  = 0.032;

B       = repmat(SpatInc, 1, NumOrient )';
A       = repmat(Angles,NumSpatFreq,1);

Combs = zeros(NumSpatFreq*NumOrient,2);
Combs(:,2) = B;

for i = 1:1:NumOrient
    foo = A(:,i);
    Combs( 1 + NumSpatFreq*(i-1) : i*NumSpatFreq) = foo;
end;

N = [];

if ~interleave
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