% two-screen (full) validity effects

% M13 files 3-37
% M16 files 6-32
% M8,9,14 9/21-10/21

mouse = inputdlg('Mouse#:');
mouse = str2double(mouse{1});

if mouse == 13
    load('psychsr\Analysis\temp\m13files.mat');
    files = files(3:37);
elseif mouse == 16
    load('psychsr\Analysis\temp\m16files.mat');
    files = files(6:32);
else
    [files, dir] = uigetfile('..\behaviorData\*.mat','MultiSelect','On');
end

