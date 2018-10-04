function trackball_sound_setup
global data
if data.params.lever>0
    psychsr_set('sound','noise_amp',0.5);
else
    psychsr_set('sound','noise_amp',0.25);
end
data.sound.noise_time = 2;
psychsr_set('sound','tone_amp',0.25);
psychsr_set('sound','tone_time',0.5);
data.sound.pahandle = 0;
data.sound.tone = 0;
data.sound.buffers = 0;   
psychsr_sound_setup();