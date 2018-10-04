function [amt time b] = psychsr_set_reward(amt)
if nargin<1
	amt = NaN;
end
time = NaN;
b = [NaN NaN];
load psychsr_reward_params;
id = find(strcmp(getenv('computername'),{params.pc}), 1);

if isempty(id)
    disp('PC not recognized, please quit and calibrate reward.')
    pause
    return
end
if now-datenum(params(id).date) > 14
    fprintf('Reward calibration is %d days old, please quit and re-calibrate.\n',round(now-datenum(params(id).date)))
%     stopFlag = input('Reward calibration more than 14 days old, continue? ');
%     if stopFlag~=1
%         error('Please quit and re-calibrate.')
%     end
end

if isnan(amt)
    amt = input('Reward (uL): ');
end
b = params(id).b;
time = (amt*b(1)+b(2))/1000;
fprintf('Reward set to %2.1fms --> %3.2fuL; press enter to confirm.\n',time*1000, amt);
pause;
return

end