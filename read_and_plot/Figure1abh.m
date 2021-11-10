clear all
close all

% Figures 1(a), (b), (h).

random_seed = 1039;
rng(random_seed)

dt = 0.01;
N = 100001;
tfin = dt*(N-1);

t = linspace(0, tfin, N);

sigma = 10.0;
rho = 28.0;
b = 8.0/3;

y0 = [-8.0, 7.0, 27.0];

% solve Lorenz using RK4.
sol = RK4(@LorenzSynth, y0, t, [sigma, rho, b]);    
% add noise.
sig = 0.01;         % change noise in this variable.
sol = sol + sig.*randn(size(sol));

N_ts = 500;         % num_tpoints - 1 

ini = 30505;
fin = ini + N_ts;

xsol = sol(ini:fin,1);
ysol = sol(ini:fin,2);
zsol = sol(ini:fin,3);

% draw original manifold.
tpoints_manifold = 6000;

figure;
plot3(sol(1:tpoints_manifold,1),sol(1:tpoints_manifold,2),sol(1:tpoints_manifold,3),'k','LineWidth',4)
xlabel('x')
ylabel('y')
zlabel('z')

grid on    

axis square
view([45 25])

set(findall(gcf,'-property','FontSize'),'FontSize',40);  

% draw time series original.
time_data = linspace(0,N_ts*dt,N_ts+1);

figure;
subplot(3,1,1)
plot(time_data,xsol,'k','LineWidth',5)
xlabel('t')
ylabel('x')
pbaspect([9.8 1 1])    

subplot(3,1,2)
xlabel('t')
ylabel('y')
pbaspect([9.8 1 1]) 
box on

subplot(3,1,3)
plot(time_data,zsol,'k','LineWidth',5)
xlabel('t')
ylabel('z')
pbaspect([9.8 1 1])    

set(findall(gcf,'-property','FontSize'),'FontSize',30);  

% draw recovered manifold.
sol_recovered = RK4(@LorenzSynth_Recovered, y0, t, [-9.9933, 17.3387, 16.1428, -1.0012, -0.5765, -2.6667, 1.7346]);

figure;
plot3(sol_recovered(1:tpoints_manifold,1),sol_recovered(1:tpoints_manifold,2),sol_recovered(1:tpoints_manifold,3),'LineWidth',4,'Color',[136,204,238]./255)
xlabel('x')
ylabel('y')
zlabel('z')

grid on    

axis square
view([45 25])

set(findall(gcf,'-property','FontSize'),'FontSize',40);  