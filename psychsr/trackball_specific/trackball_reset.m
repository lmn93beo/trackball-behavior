function trackball_reset
    if ~isempty(instrfind)
        fclose(instrfind);
        delete(instrfind);
    end
    daqreset;
    
    disp('Open trackball-usb-ao in Arduino.')
    disp('Then open Serial Monitor: Ctrl+Shift+M')
end