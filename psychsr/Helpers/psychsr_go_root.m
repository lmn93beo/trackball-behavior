function folder = psychsr_go_root()
    pc = getenv('computername');        
    if strcmp(pc,'ANALYSIS-2P4') || strcmp(pc,'BEHAVE-BALL1')
        folder = 'C:\Users\Surlab\Dropbox\MouseAttention\matlab';         
    elseif strcmp(pc,'GERALD-LAB')
        folder = 'H:\Dropbox (MIT)\MouseAttention\matlab';
    elseif strcmp(pc,'WFSTIM')
        folder = 'C:\Users\Liadang\Dropbox\MouseAttention\matlab';    
    elseif strcmp(pc,'RAFIQ-PC')
        folder = 'C:\Users\Rafiq\Dropbox (MIT)\MouseAttention\matlab';
    elseif strcmp(pc,'BEHAVE-BALL3')
        folder = 'C:\Users\surlab\Dropbox\MouseAttention\Matlab';
    elseif strcmp(pc,'VISSTIM-2P4')
        folder = 'C:\Users\Surlab\Dropbox\MouseAttention\Matlab';
    else
        folder = 'C:\Dropbox\MouseAttention\matlab';    
    end
    
    cd(folder)
end