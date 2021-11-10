clear all
close all

% Figure 4(a).

%%% real data.
fileID = fopen('circuit_x_Fig3.txt','r');
formatSpec = '%f';
xcircuit = fscanf(fileID,formatSpec);

fileID = fopen('circuit_z_Fig3.txt','r');
formatSpec = '%f';
zcircuit = fscanf(fileID,formatSpec);     

N_real = 501;
N_steps = 2;
N = N_steps*N_real;
dt = 0.01;

t = linspace(0,dt*(N_real-1), N_real);

ini = 3025;
fin = ini + N - 1;

figure;
subplot(3,1,1)
plot(t,xcircuit(ini:N_steps:fin),'k','LineWidth',5)
xlabel('t')
ylabel('x')
pbaspect([9.8 1 1])
ylim([-5,5])

subplot(3,1,2)
xlabel('t')
ylabel('y')
pbaspect([9.8 1 1]) 
ylim([-5,5])
box on

subplot(3,1,3)
plot(t,zcircuit(ini:N_steps:fin),'k','LineWidth',5)
xlabel('t')
ylabel('z')
pbaspect([9.8 1 1])    

set(findall(gcf,'-property','FontSize'),'FontSize',30); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_steps = 2;
N = N_steps*20001;

ini = 15;
fin = ini + N - 1;

figure;
plot3(xcircuit(ini:N_steps:fin),xcircuit(ini-6:N_steps:fin-6),zcircuit(ini:N_steps:fin),'k','LineWidth',2)
xlabel('x')
ylabel('x(t-\tau)')
zlabel('z')

grid on    

axis square
view([45 25])

set(findall(gcf,'-property','FontSize'),'FontSize',40);       

