function new_loop = psychsr_plasticity_feedback(loop)

global data;

if loop.response
    % print time of lick
    fprintf('%s %4d',datestr(loop.prev_flip_time/86400,'MM:SS'),length(data.response.licks));
	fprintf('\n');
end

% previous stimulus type
if loop.stim>2 && strcmp(data.stimuli.stim_type{loop.stim-2},'image')
    if strcmp(data.stimuli.movie_file{loop.stim-2},data.stimuli.target_movie)
        if loop.frame-loop.new_stim==1
			if max(data.response.licks) - max(data.response.rewards) < 0
				fprintf('%s FREE',datestr(loop.prev_flip_time/86400,'MM:SS'));
				fprintf('\n');
			else
				psychsr_reward(loop,0);
			end
        end
    end
end



new_loop = loop;
end