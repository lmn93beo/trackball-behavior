function psychsr_move_spout(loop, direction)
% direction: 1=extend, 2=retract
global data;

psychsr_set('response','spout_time',0.4);

if max(data.response.mode == [5, 6, 7, 8])
    if direction == 1
        data.response.extends(end+1) = loop.prev_flip_time;
        outdata = data.card.dio.UserData;
        outdata.dt(2) = data.response.spout_time;
        outdata.tstart(2) = NaN;
        data.card.dio.UserData = outdata;
    elseif direction == 2
        data.response.retracts(end+1) = loop.prev_flip_time;
        outdata = data.card.dio.UserData;
        outdata.dt(3) = data.response.spout_time;        
        outdata.tstart(3) = NaN;
        data.card.dio.UserData = outdata;
    end
end