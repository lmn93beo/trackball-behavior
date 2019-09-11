% function order = gpi_rfsn_randomize(rects,colors,repeats)
order = [];
dist = 1.9;
n = length(colors);
for i = 1:repeats
	order = [order;randperm(n)'];
end
count = 0;
for j = 1:repeats
	i=1;
	if j==1
		i = 2;
	end
	while i<= n
		% check proximity
		if (abs(rects(order(i+n*(j-1)),1)-rects(order(i+n*(j-1)-1),1))*nvert<=dist) && ...
				(abs(rects(order(i+n*(j-1)),2)-rects(order(i+n*(j-1)-1),2))*nhoriz<=dist)
			temp = order(i+n*(j-1));
			if i < n
				newidx = randi(n-i)+i+n*(j-1);
			else % last position
				newidx = randi(n-2)+1+n*(j-1);
				while (abs(rects(order(i+n*(j-1)),1)-rects(order(newidx-1),1))*nvert<=dist) && ...
						(abs(rects(order(i+n*(j-1)),2)-rects(order(newidx-1),2))*nhoriz<=dist) && ...
						(abs(rects(order(i+n*(j-1)),1)-rects(order(newidx+1),1))*nvert<=dist) && ...
						(abs(rects(order(i+n*(j-1)),2)-rects(order(newidx+1),2))*nhoriz<=dist)
					newidx = randi(n-2)+1+n*(j-1);
				end
			end
			order(i+n*(j-1)) = order(newidx);
			order(newidx) = temp;
			count = count+1;
			if count > 10000
				disp('failed')
				return;
			end			
			fprintf('%d %d\n',i,count)
		else
			i = i+1;
		end
	end
end