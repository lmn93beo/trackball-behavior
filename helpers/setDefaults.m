opengl software

% set the default figure position to be in the upper right
scrn = get(0,'screensize');
pos = zeros(size(scrn));
pos(4) = 420; % height
pos(2) = scrn(4)-pos(4)-80;  % top (from bottom)
pos(3) = 560; % width
pos(1) = scrn(1); % left (from left)

set(0,'defaultFigurePosition',pos)
% set the default figure color to be white
set(0,'defaultFigureColor',[1 1 1])
% set the default font size to be 14
set(0,'defaultaxesfontsize',14);
set(0,'defaulttextfontsize',14);

set(0,'defaultUicontrolFontName','Arial');
set(0,'defaultUitableFontName','Arial');
set(0,'defaultAxesFontName','Arial');
set(0,'defaultTextFontName','Arial');
set(0,'defaultUipanelFontName','Arial');