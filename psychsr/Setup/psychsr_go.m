function psychsr_go()
% load psychsr functions into workspace

	functions_directory = which('psychsr');
	functions_directory = functions_directory(1:end-10);
	addpath(genpath(functions_directory));

end