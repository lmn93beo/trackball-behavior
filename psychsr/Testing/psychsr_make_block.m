function psychsr_make_block(stage_num,block_size)
%% setup variables
variable_names = {...
    'per_targ',...              % percent targets
    'resp', ...                 % response window (s)
    'grace_period',...          % grace period (s)
    'nt', ...                   % nontarget speed (Hz)
    'delay', ...                % delay period (s)
    'delay_var', ...            % range of variance of delay (s)
    'sides', ...                % vector indicating screen
    'aperture', ...             % vector indicating grating size
    'mcontrast', ...            % movie contrast
 };

% default values
values = {1, 4, 1, 0.2, 2, 0, 2*ones(1,block_size), [0 0 1 1], 0};

%% description of stages
switch stage_num
    case 1 % detection        
        
    case 2 % discrim 75%
        values{1} = 0.75;
    
    case 3 % discrim 75%, resp = 3, grace_period = 0.25
        values{1:3} = {0.75, 3, 0.25};
    
    case 4 % discrim 66%
        values{1:3} = {2/3, 3, 0.25};
    
    case 5 % discrim 50%
        values{1:3} = {0.5, 3, 0.25};
    
    case 6 % discrim 50%, increase NT speed and delay
        values{1:5} = {0.5, 3, 0.25, 1, 3};
    
    case 7 % discrim 50%, max NT speed, vary delay
        values{1:6} = {0.5, 3, 0.25, 2, 3, 1};

    case 8 % left screen only
        values{1:7} = {0.5, 3, 0.25, 2, 3, 1, ones(1,block_size)};
        
    case 9 % alternate screens
        values{1:7} = {0.5, 3, 0.25, 2, 3, 1, 1+mod(1:block_size,2)};
        
    case 10 % random screens
        values{1:7} = {0.5, 3, 0.25, 2, 3, 1, psychsr_rand(0.5,num_loops,0,3)};
        
    case 11 % resp = 2.5
        values{1:8} = {0.5, 3, 0.25, 2, 3, 1, ...
            psychsr_rand(0.5,num_loops,0,3), 2.5};
        
    case 12 % resp = 2
        values{1:8} = {0.5, 3, 0.25, 2, 3, 1, ...
            psychsr_rand(0.5,num_loops,0,3), 2};
        
    case 13 % resp = 1.5
        values{1:8} = {0.5, 3, 0.25, 2, 3, 1, ...
            psychsr_rand(0.5,num_loops,0,3), 1.5};
        
    case 14 % resp = 1
        values{1:8} = {0.5, 3, 0.25, 2, 3, 1, ...
            psychsr_rand(0.5,num_loops,0,3), 1};
        
    case 15 
end

eval_string = [];
for i = 1:length(variable_names)
    eval_string=[eval_string,variable_names{i}, '=values{',num2str(i),'}; '];    
end
eval(eval_string);

%% make block

