function data = psychsr_train()

% select mouse
mouse = input('Mouse #: ');
file = sprintf('psychsr/protocols/mice/%04d.mat',mouse);

% load previous parameters for this mouse
if exist(file,'file') == 2 
    load(file);
    disp(params(end))
    
% new mouse
else
    params = struct;
    params(1).start_time = now;
    params(1).program = 'psychsr_train_lick.m';
    params(1).reward_amt = 4;    
end

end