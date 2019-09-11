function N = GenerateCombinations_for_dendImaging

NumSpatFreq = 1;
NumOrient   = 12;
% minSpatFreq = 0;
% maxSpatFreq = 32; % i.e 0.1 cyc/px

% range of spatial freqs = 0.01 cyc/px -> .6 cyc/px
% range of angles = 22.5 deg -> 360 deg

% SpatInc = [1,2,3,4,6,8,10,16];
% SpatInc = linspace( minSpatFreq, maxSpatFreq, NumSpatFreq);
Angles  = linspace(0, 330, NumOrient);
% SpatInc = [0.005*2.^(0:NumSpatFreq-1)];
SpatInc  = 0.008.*ones(1,1);

B       = repmat(SpatInc, 1, NumOrient )';
A       = repmat(Angles,NumSpatFreq,1);

Combs = zeros(NumSpatFreq*NumOrient,2);
Combs(:,2) = B;

for i = 1:1:NumOrient
    foo = A(:,i);
    Combs( 1 + NumSpatFreq*(i-1) : i*NumSpatFreq) = foo;
end;

N = [];
for i = 1:5
    N = [N; Combs ];
end;