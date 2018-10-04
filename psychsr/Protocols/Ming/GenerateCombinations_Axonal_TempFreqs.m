function N = GenerateCombinations_Axonal_TempFreqs

NumTempFreq = 5;
NumOrient   = 4 ;

Angles  = linspace(0, 270, NumOrient);
% SpatInc =  [0.002*2.^(1:NumSpatFreq)];
TempInc  =  [0.5 1 2 4 8];

B       = repmat(TempInc, 1, NumOrient )';
A       = repmat(Angles,NumTempFreq,1);

Combs = zeros(NumTempFreq*NumOrient,2);
Combs(:,2) = B;

for i = 1:1:NumOrient
    foo = A(:,i);
    Combs( 1 + NumTempFreq*(i-1) : i*NumTempFreq) = foo;
end;

N = [];
for i = 1:10
    N = [N; Combs(randperm(size(Combs,1)),:) ];
end;