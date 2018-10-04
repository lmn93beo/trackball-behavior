b = 60;
t = 1000;

m = [0.5, 0.7, 0.9];

d = 0.3*ones(t,b,length(m)); % repeats X trials/block X mice 

for j = 1:t

    p = zeros(b,length(m));
    for k = 1:length(m)
        p(:,k) = rand(b,1)< m(k);    
    end

n = ones(1,length(m));


for i = 1:b  
    for k = 1:length(m)
%         if n(k) >= 5 &&  mean(p(i-4:i,k))>0.6 && d(j,i,k) < 0.91 
%             d(j,i+1:end,k) = d(j,i+1:end,k)+0.1;
%             n(k) = 0;
%         end
%         if n(k) >= 5 &&  mean(p(i-4:i,k))<0.6 && d(j,i,k) > 0.09 
%             d(j,i+1:end,k) = d(j,i+1:end,k)-0.1;
%             n(k) = 0;
%         end
            
        
        if n(k) >= 6 && mean(p(i-5:i,k))>0.9 && d(j,i,k) < 0.91 %&& mod(i,5) == 0
            d(j,i+1:end,k) = d(j,i+1:end,k)+0.1;
            n(k) = 0;
        end
        if n(k) >= 10 && mean(p(i-9:i,k))>0.7 && d(j,i,k) < 0.91 && mod(i,5) == 0
            d(j,i+1:end,k) = d(j,i+1:end,k)+0.1;
            n(k) = 0;
        end

%         if n(k) >= 2 && mean(p(i-1:i,k)) > 0.9 && d(j,i,k) < 0.91
%             d(j,i+1:end,k) = d(j,i+1:end,k)+0.1;
%             n(k) = 0;
%         elseif p(i,k) == 0 && d(j,i,k) > 0.04
%             d(j,i+1:end,k) = d(j,i+1:end,k)-0.05;
%         end        
        
    end
    n = n +1;
end
        
end

% close all
figure
subplot(2,1,1)
plot(reshape(mean(d),[],length(m)))
subplot(2,1,2)
bin = 0.1:0.1:1;
n = hist(reshape(max(d,[],2),[],length(m)),bin);
bar(bin,n/10)
xlim([0 1.05])