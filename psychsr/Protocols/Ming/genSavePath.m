function [T,Params] =  genSavePath(exptType,Params,folderName)

fprintf('Creating Folders .....');
if exist( ['../' date '/'] ) < 7
	mkdir( ['../' date '/'] );
end;

if exist( ['../' date folderName] ) <7
	mkdir( ['../' date folderName] )
end;
savePath = ['../' date folderName];
fprintf('..... Done!\n');


switch exptType
	case 'fresh'
		
        % generate and save the protocol used .....................................
		fprintf('Generating Random Seqeuence .....');
		T =  repmat(1:Params.NumMovies, 1, Params.NumTrials_perMov );
		T =  T(randperm(length(T)));
		T = reshape(T, Params.MovsperTrial, Params.NumTrials);
		
		X = dir(['../' date folderName '*.mat']);
		if size(X,1) == 0
			% this is the first protocol..
			ctr = 1;
			Params.runNumber = ctr;
			
		elseif size(X,1) > 0
			% if this code is run more than 1 time in the same day, the ctr will
			% increment and the highest number will be the latest seqeunce. If the
			% code is run only once in the day, the ctr will remain at 1.
			foo = X( size(X,1), 1);
			v   = sprintf( foo.name );
			v   = v(10:end);
			for q = 1:length(v)
				if strcmp(v(q),'.') == 1
					locdot(q) = 1;
				else
					locdot(q) = 0;
				end;
			end;
			runNum = str2num(v(1 : find(locdot == 1 )));
			ctr =  runNum + 1;
			Params.runNumber = ctr;
		end;
		clear foo locdot v
		save( [savePath 'Protocol_' num2str(ctr)], 'T', 'Params' )
		fprintf('..... Saved!\n');
        
	case 'previous'
		X = dir(['../' date folderName '*.mat']);
		foo = X( size(X,1), 1);
		load( [savePath '/' foo.name] );	
end;