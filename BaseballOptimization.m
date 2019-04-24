% This script will read in the player data and output the c and b vector
% along with the A matrix for the baseball ILP problem
clear
clc
[~,~,rocks] = xlsread('Updated Player Data.xlsx','Rockies Summary');
% raw output is cell matrix with all data
% column 2 is names
% col 3 is position
% col 5 is WAR
% row 2-41 contains all player data
rplayer = cell(40,1);
rpos = cell(40,1);
rWAR = zeros(40,1);
check = zeros(40,1);
rsal = zeros(40,1);
for i = 2:(size(rocks,1)-3)
  if strcmpi(rocks{i,6},'IGNORE')
      check(i-1) = 1; 
  end
  rplayer{i-1} = rocks{i,2}; % player name
   rpos{i-1} = rocks{i,3}; 
   rWAR(i-1) = rocks{i,5}; % rockies WAR vals 
end
% delete ignored players
rWAR(logical(check)) = [];
rplayer(logical(check)) = [];
rsal(logical(check)) = [];
rpos(logical(check)) = [];
% now load in FA data

[~,~,FA] = xlsread('Updated Player Data.xlsx','Free Agents WAR & Salary');


FAplayer = cell(204,1);
FApos = cell(204,1);
FAWAR = zeros(204,1);
FAcheck = zeros(204,1);
FAsal = zeros(204,1);

for i = 2:size(FA,1)
   
   if isnan(FA{i,6}) || FA{i,15} == 0 || strcmpi(FA{i,2},'DH')
       FAcheck(i-1) = 1;
   end
    
   if isnan(FA{i,14})
       if isnan(FA{i,9})
           FAcheck(i-1) = 1;
       else
           FAsal(i-1) = 1e6*FA{i,10}/FA{i,9};
       end
   else
   FAsal(i-1) = 1e6*FA{i,15}/FA{i,14}; 
   end
   FAplayer{i-1} = FA{i,1}; % player name
   FApos{i-1} = FA{i,2}; 
   FAWAR(i-1) = FA{i,6}; % rockies WAR vals     
end

% now delete ignored entries
FAWAR(logical(FAcheck)) = [];
FAplayer(logical(FAcheck)) = [];
FAsal(logical(FAcheck)) = [];
FApos(logical(FAcheck)) = [];

% now, stack all players together
WAR = [rWAR;FAWAR];
player = [rplayer;FAplayer];
sal = [rsal;FAsal];
pos = [rpos;FApos];

% now create P vectors based on pos data
L = length(sal);
P0 = zeros(1,L);
P1 = zeros(1,L);
P2 = zeros(1,L);
P3 = zeros(1,L);
P4 = zeros(1,L);
P5 = zeros(1,L);
P6 = zeros(1,L);
P7 = zeros(1,L);
P8 = zeros(1,L);
P9 = zeros(1,L);

for i = 1:L
   p = strsplit(pos{i},'/');
   for j = 1:length(p)
       % populate P based on conditionals
       if strcmpi(p{j},'RP')
           P0(i) = 1;
       end
       if strcmpi(p{j},'SP')
           P1(i) = 1;
       end
       if strcmpi(p{j},'C')
           P2(i) = 1;
       end
       if strcmpi(p{j},'1B')
           P3(i) = 1;
       end
       if strcmpi(p{j},'2B')
           P4(i) = 1;
       end
       if strcmpi(p{j},'3B')
           P5(i) = 1;
       end
       if strcmpi(p{j},'SS')
           P6(i) = 1;
       end
       if strcmpi(p{j},'LF')
           P7(i) = 1;
       end
       if strcmpi(p{j},'CF')
           P8(i) = 1;
       end
       if strcmpi(p{j},'RF')
           P9(i) = 1;
       end
   end
end

%% now build A matrix based on constraints

% 1st: relief pitchers
A(1,:) = -[P0,zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),...
    zeros(1,L),zeros(1,L),zeros(1,L)];
b(1) = -7;

% starters - EQUALITY CONSTRAINT
A(2,:) = [zeros(1,L),P1,zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),...
    zeros(1,L),zeros(1,L),zeros(1,L)];
b(2) = 5;
A(3,:) = -A(2,:);
b(3) = -5;

% catchers
A(4,:) = -[zeros(1,L),zeros(1,L),P2,zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),...
    zeros(1,L),zeros(1,L),zeros(1,L)];
b(4) = -2;
% 1B
A(5,:) = -[zeros(1,L),zeros(1,L),zeros(1,L),P3,zeros(1,L),zeros(1,L),zeros(1,L),...
    zeros(1,L),zeros(1,L),zeros(1,L)];
b(5) = -1;
% 2B
A(6,:) = -[zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),P4,zeros(1,L),zeros(1,L),...
    zeros(1,L),zeros(1,L),zeros(1,L)];
b(6) = -1;
% 3B
A(7,:) = -[zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),P5,zeros(1,L),...
    zeros(1,L),zeros(1,L),zeros(1,L)];
b(7) = -1;
% SS
A(8,:) = -[zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),P6,...
    zeros(1,L),zeros(1,L),zeros(1,L)];
b(8) = -1;
% infielders
A(9,:) = -[zeros(1,L),zeros(1,L),zeros(1,L),P3,P4,P5,P6,...
    zeros(1,L),zeros(1,L),zeros(1,L)];
b(9) = -5;
% LF
A(10,:) = -[zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),...
    P7,zeros(1,L),zeros(1,L)];
b(10) = -1;
% CF
A(11,:) = -[zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),...
    zeros(1,L),P8,zeros(1,L)];
b(11) = -1;
% RF
A(12,:) = -[zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),...
    zeros(1,L),zeros(1,L),P9];
b(12) = -1;
% outfielders
A(13,:) = -[zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),zeros(1,L),...
    P7,P8,P9];
b(13) = -4;

% versatility constraint
for i = 1:L
    A(13+i,:) = zeros(1,10*L);
    for j = 0:9
        A(13+i,i+j*L) = 1;
    end
    b(13+i) = 1;
end

% salary constraint
a = repmat(sal,10);
a = a(:,1);
a = a'; % row vector
A(13+L+1,:) = a;
B = 11501312; % FA budget (adjust this as needed) 
b(13+L+1) = B;

% lastly: only 25 players allowed - EQUALITY CONSTRAINT
A(13+L+2,:) = [P0,P1,P2,P3,P4,P5,P6,P7,P8,P9];
b(13+L+2) = 25;
A(13+L+3,:) = -[P0,P1,P2,P3,P4,P5,P6,P7,P8,P9];
b(13+L+3) = -25;


% finally, put together big WAR matrix
% assumes WAR is the same for all positions for all players

c = repmat(WAR,10);
c = c(:,1);

play = repmat(player,10);
play = play(:,1);
player = play;

% DONE! now save A,b,c and player name data

save('A.mat','A')
save('b.mat','b')
save('c.mat','c')
save('players.mat','player')

% Now, solve the ILP problem using optimization toolbox!

intcon = (1:length(c))';
f = -c;
lb = zeros(length(c),1);
ub = ones(length(c),1);
Aeq = [];
beq = [];

x = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);

% now find which players made the cut!

list = find(x);
roster = player(list);



















       













