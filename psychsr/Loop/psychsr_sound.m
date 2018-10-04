function psychsr_sound(sound_num)

    global data;
    
	persistent buffered_sound;
    
	if data.sound.on == 1
		if isempty(buffered_sound)
			buffered_sound = -1;
		end
		
		pahandle = data.sound.pahandle;
		buffers = data.sound.buffers;
		
		status = PsychPortAudio('GetStatus', pahandle);
		if status.Active == 0
			% only play if previous sound has stopped
			
			if sound_num == 1 && data.sound.noise_amp > 0
				%             if buffered_sound > 3
				%                 % wait for tone to finish
				%             else
				%                 PsychPortAudio('Stop',pahandle,2); % interrupt current sound
				%             end
				% play noise
				if buffered_sound ~= sound_num
					PsychPortAudio('FillBuffer', pahandle, buffers(sound_num));
					buffered_sound = sound_num;
				end
				PsychPortAudio('Start',pahandle,1,0,0);
				
			elseif (sound_num > 1 && data.sound.tone_amp > 0) || sound_num>10
				%             PsychPortAudio('Stop',pahandle,2); % interrupt current sound
				
				% play tone
				if buffered_sound ~= sound_num
					PsychPortAudio('FillBuffer', pahandle, buffers(sound_num));
					buffered_sound = sound_num;
				end
				PsychPortAudio('Start',pahandle,1,0,0);
				
			end
			
		elseif sound_num == 6 || sound_num == 1 || sound_num == 7 || sound_num == 16 || sound_num == 3 % exception for clicks/noise
			PsychPortAudio('Stop',pahandle,2); % interrupt current sound
			if buffered_sound ~= sound_num
				PsychPortAudio('FillBuffer', pahandle, buffers(sound_num));
				buffered_sound = sound_num;
			end
			PsychPortAudio('Start',pahandle,1,0,0);
		else
			fprintf(' MUTE')
		end
           
	end
end