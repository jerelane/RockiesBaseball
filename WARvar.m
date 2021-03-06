function [WAR,Brange] = WARvar(f,intcon,A,b,Aeq,beq,lb,ub,Blim)
%This function iterates through budget values to see how WAR changes w/ $

% solve time is about 1/2 second, so let it run for 1 hr to get data
numits = 100;
Brange = linspace(0,Blim,numits);
L = size(A,2)/10;
c = -f;
for i = 1:numits
    B = Brange(i);
    b(11+L+1) = B;

x = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);

% now find which players made the cut!

list = find(x);
% roster = player(list);

rosterWAR = c(list);
WAR(i) = sum(rosterWAR);

end

% figure
% plot(B/(1e6),WAR,'LineWidth',2)
% title('WAR vs Budget')
% xlabel('Budget (Millions of Dollars)')
% ylabel('Total WAR')


end

