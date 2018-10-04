path1 = uigetdir;
[root1 dir1] = fileparts(path1);
dir1
cd([root1 '\' dir1])

root2 = 'C:\temp'; %uigetdir;

if exist([root2 '\' dir1],'dir')==0
    mkdir([root2 '\' dir1])
end

for i = 1:4
    sub1 = ['plane' num2str(i)];    
    files = dir([sub1 '\*.mat']);
    
    path2 = [root2 '\' dir1 '\' sub1];
    
    if exist(path2,'dir')==0
        mkdir(path2)
    end
    
    
    for j = 1:length(files)        
        copyfile([sub1,'\',files(j).name],[path2,'\',files(j).name])
    end
end