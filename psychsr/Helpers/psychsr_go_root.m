function folder = psychsr_go_root()
    pc = getenv('computername');        
    switch pc
        case 'BEHAVE-BALL2'
            folder = 'C:\Dropbox\nhat';
        case 'BEHAVE-BALL1'
            folder = 'C:\Users\surlab\Dropbox\Nhat\trackball-behavior';
    end
    
    cd(folder)
end