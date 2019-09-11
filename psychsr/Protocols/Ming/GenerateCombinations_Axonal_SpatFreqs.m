function N = GenerateCombinations_Axonal_SpatFreqs

NumSpatFreq = 5;
NumOrient   = 4 ;

Angles  = linspace(0, 270, NumOrient);
% SpatInc =  [0.002*2.^(1:NumSpatFreq)];
SpatInc  =  [0.0160 0.0320 0.064 0.1280 0.256];

B       = repmat(SpatInc, 1, NumOrient )';
A       = repmat(Angles,NumSpatFreq,1);

Combs = zeros(NumSpatFreq*NumOrient,2);
Combs(:,2) = B;

for i = 1:1:NumOrient
    foo = A(:,i);
    Combs( 1 + NumSpatFreq*(i-1) : i*NumSpatFreq) = foo;
end;

N = [];
for i = 1:10
    N = [N; Combs(randperm(size(Combs,1)),:) ];
end;