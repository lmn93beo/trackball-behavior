function [amt time b] = psychsr_set_quinine(amt)
if nargin<1
	amt = NaN;
end
time = NaN;
b = [NaN NaN];
load psychsr_quinine_params;
id = find(strcmp(getenv('computername'),{params.pc}), 1);

if isempty(id)
    disp('PC not recognized, please quit and calibrate quinine.')
    return
end
if now-datenum(params(id).date) > 14
    fprintf('Quinine calibration is %d days old, please quit and re-calibrate.\n',round(now-datenum(params(id).date)))
    pause;
end

if isnan(amt)
    amt = input('Quinine (uL): ');
end
b = params(id).b;
time = (amt*b(1)+b(2))/1000;
if amt == 0
    time = 0;
end
fprintf('Quinine set to %2.1fms --> %3.2fuL; press enter to confirm.\n',time*1000, amt);
% pause;
return

end