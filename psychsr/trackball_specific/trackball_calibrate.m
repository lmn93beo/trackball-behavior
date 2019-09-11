function trackball_calibrate(ntrials)
if nargin<1 || isempty(ntrials)
    ntrials = 16;    
end

psychsr_go_root();
cd gerald\newbehavior

load trackball_calibration
id = find(strcmp(getenv('computername'),{params.pc}));
if isempty(id)
    id = length(params)+1;
    params(id).pc = getenv('computername');
end

global data
data.screen.pc = getenv('computername');
data.params.lever = 0;
data.params.laser = 0;
data.params.notify = '';
trackball_card_setup 
trackball_sound_setup

mvmt_test = true;
fprintf('testing, waiting for mvmt...\n')
while mvmt_test
    bytes = data.serial.in.BytesAvailable;
    while bytes > 4
        [d,b] = fscanf(data.serial.in,'%d'); % read x and y
        bytes = bytes-b;
        if length(d) == 2 && d(2)~= 0
            mvmt_test = false;
            break;
        end
    end
    pause(0.1);
end
fprintf('Prepare to move ball, 360 degrees per trial, 5s per trial\n.')
fprintf('%d times left, %d times right, in any order.\n',ntrials/2,ntrials/2)
fprintf('Press any key to begin each trial.\n')
while ~KbCheck
    bytes = data.serial.in.BytesAvailable;
    while bytes > 4
        [d,b] = fscanf(data.serial.in,'%d');
        bytes = bytes-b;
    end
end
%%
mvmts = zeros(1,ntrials);

for i = 1:ntrials
    fprintf('Trial %d\n',i)
    psychsr_sound(17)
        
    tstart = tic;
    
    while toc(tstart)<5
        bytes = data.serial.in.BytesAvailable;
        while bytes > 4
            [d,b] = fscanf(data.serial.in,'%d');
            bytes = bytes-b;
            if length(d) == 2
                mvmts(i) = mvmts(i)+d(2);
            end
        end
        pause(0.1);
    end
    disp(mvmts(i))
    
    psychsr_sound(3)    
    tstart = tic;
    while toc(tstart)<2
        bytes = data.serial.in.BytesAvailable;
        while bytes > 4
            [d,b] = fscanf(data.serial.in,'%d');
            bytes = bytes-b;
        end
    end
end

%%
right = find(mvmts<0); % right
left = find(mvmts>0); % right

mleft = median(abs(mvmts(left)));
mright = median(abs(mvmts(right)));

figure
hold on
plot(1:length(left),abs(mvmts(left)),'ob','markerfacecolor','b')
plot([1 length(left)],mleft*[1 1],'b')
plot(20+(1:length(right)),abs(mvmts(right)),'or','markerfacecolor','r')
plot([1 length(right)]+20,mright*[1 1],'r')

if ~isempty(params(id).cal)
    plot([1 length(left)],360/params(id).cal(1)*[1 1],':b')
    plot(20+[1 length(right)],360/params(id).cal(2)*[1 1],':r')
end


s = [];
while isempty(s) || isnan(s) || ~isnumeric(s)
    try s = input('Save? (0/[1]): ');
    catch
        fprintf('\n');
        s = [];
    end
end

if s==1
    params(id).date = clock;
    params(id).mvmts = mvmts;
    params(id).cal = [360 360]./[mleft mright]; % degrees per pixel
    save('trackball_calibration.mat','params');
end

%%
fclose(data.serial.in);
delete(data.serial.in);
data.serial = rmfield(data.serial,'in');
putvalue(data.card.dio,0);
stop(data.card.dio)
delete(data.card.dio);
data.card = rmfield(data.card,'dio');
data.card = rmfield(data.card,'trigger');
stop(data.card.ai);
delete(data.card.ai);
data.card = rmfield(data.card,'ai');