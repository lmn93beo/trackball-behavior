% loads filenames from a directory more quickly
function files = fastdir
    x=java.io.File('.').listFiles();
    files = cell(size(x));
    for i = 1:length(x)
        filename = char(x(i));
        files(i) = {filename(3:end)}; % remove .\
    end
end