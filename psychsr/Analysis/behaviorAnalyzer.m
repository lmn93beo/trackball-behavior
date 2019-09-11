%%% behaviorAnalyzer

mouse_list = {76,77,79,80,82,84,88,89,90,91};
master_date = ['20' num2str(input('current date ? (YYMMDD) '))];

for i = 1:length(mouse_list)
    try cd(sprintf('mouse %04d',mouse_list{i}))
        curr_date = master_date;
        loopFlag=0;
        while loopFlag~=1
            try
                load([curr_date '_discrim_' sprintf('%04d',mouse_list{i})]);
            catch
                disp('Date not found, try again')
                curr_date = ['20' num2str(input('current date ? (YYMMDD) '))];
            end
            disp(' ')
            disp(data.response.summary);
            loopFlag = input('Continue? (1) or Examine another date? (YYMMDD) ');
            if loopFlag~=1
                curr_date = ['20' num2str(loopFlag)];
            end
        end
        cd ..
    catch
        disp(' ')
        disp([sprintf('mouse %04d',mouse_list{i}) ' not found'])
    end
end
        