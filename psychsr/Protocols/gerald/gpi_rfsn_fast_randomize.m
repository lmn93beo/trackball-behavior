function order = gpi_rfsn_fast_randomize(rects,colors,repeats,nvert,nhoriz)
order = [];
n = length(colors);
for i = 1:repeats
	order = [order;randperm(n)'];
end
order(order>nhoriz^2 & order<=nvert*nhoriz)=[];
order(order>nhoriz*(nvert+nhoriz) & order<=2*nvert*nhoriz)=[];
n = length(order)/2;

dist = 2;

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
				while (abs(rects(order(i+n*(j-1)),1)-rects(order(newidx-1),1))*nvert<=3) && ...
						(abs(rects(order(i+n*(j-1)),2)-rects(order(newidx-1),2))*nhoriz<=3) && ...
						(abs(rects(order(i+n*(j-1)),1)-rects(order(newidx+1),1))*nvert<=3) && ...
						(abs(rects(order(i+n*(j-1)),2)-rects(order(newidx+1),2))*nhoriz<=3)
					newidx = randi(n-2)+1+n*(j-1);
				end
			end
			order(i+n*(j-1)) = order(newidx);
			order(newidx) = temp;
			count = count+1;						
			fprintf('%d %d\n',i,count)
			
		else
			i = i+1;
		end
	end
end