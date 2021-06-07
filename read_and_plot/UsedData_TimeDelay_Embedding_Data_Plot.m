clear all

load('Variables_Plotting_Circuit.mat')

%% Plot time series used in algorithm of experimental data.
% Figure 1(a)
N_501 = 501;
N_used_data = sampling_rate*N_501;
time_data = linspace(0,N_501*dt-dt,N_501);

ini = 3025;
fin = ini + N_used_data - 1;

figure;
subplot(2,1,1)
plot(time_data,xcircuit(ini:sampling_rate:fin),'k','LineWidth',5)
xlabel('t')
ylabel('x [V]')

subplot(2,1,2)
plot(time_data,zcircuit(ini:sampling_rate:fin),'k','LineWidth',5)
xlabel('t')
ylabel('z [V]')

set(findall(gcf,'-property','FontSize'),'FontSize',30);  

%% Plot time-delay embedding of experimental data.
% Figure 1(a)
N_steps = 2;
N = N_steps*22001;

ini = 3;
fin = ini + N - 1;

tdelay = 2;

figure;
plot3(xcircuit(ini:N_steps:fin),xcircuit(ini-tdelay:N_steps:fin-tdelay),zcircuit(ini:N_steps:fin),'k','LineWidth',2)
xlabel('x')
ylabel('x(t-\tau)')
zlabel('z')

grid on    

axis square
view([45 25])

set(findall(gcf,'-property','FontSize'),'FontSize',40);  