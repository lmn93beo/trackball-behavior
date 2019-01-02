% collect extra serial samples  -- RH    
global data
if data.params.lever>0
    trackball_getdata(2);
else
    while data.serial.in.BytesAvailable > 4
        trackball_keycheck(k);            
        trackball_getdata(2);
    end
end