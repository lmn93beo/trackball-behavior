function folder = psychsr_go_root()
    pc = getenv('computername');        
    switch pc
        case 'BEHAVE-BALL2'
            folder = 'C:\Dropbox\nhat';    
    end
    
    cd(folder)
end