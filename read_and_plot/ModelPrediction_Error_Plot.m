clear all

load('Variables_Plotting_Circuit.mat')

%% Plot time-series comparing all models.
% Figure 1(f)

% initial point given by kk
kk = 20;

for i = 1:length(lowest_level)    
    jj = lowest_level(i);

    dt = 0.01;
    t_plot = 0:dt:2;
    num_tpoints = 91;

    y0 = ypredicted_x(jj,kk);
    X0 = [X_real{kk}(1,1), y0, X_real{kk}(1,3)];

    sol_model_figure = RK4(@Lorenz_Generic, X0, t_plot, parameters_model(jj,:));
    X_simx = sol_model_figure(:,1);
    X_simy = sol_model_figure(:,2);            
    X_simz = sol_model_figure(:,3);

    figure(101);
    subplot(3,1,1)
    plot(t_plot,X_simx,'-','LineWidth',3,'Color',colours(i,:));     
    hold on    
    plot(t_plot,xcircuit(ini_c(kk):sampling_rate:ini_c(kk)+(length(t_plot)*2-1)),'-k','LineWidth',3);
    hold on
    xline(num_tpoints*dt,'-','LineWidth',3);    
    ylabel('x')   

    xlim([0,t_plot(end)])

    pbaspect([1.66 .25 1]) 

    subplot(3,1,2)
    hold on
    plot(t_plot,X_simy,'-','LineWidth',3,'Color',colours(i,:));    
    hold on
    xline(num_tpoints*dt,'-','LineWidth',3);  
    box on
    ylabel('y')   

    xlim([0,t_plot(end)])

    pbaspect([1.66 .25 1])

    subplot(3,1,3)
    plot(t_plot,X_simz,'-','LineWidth',3,'Color',colours(i,:));        
    hold on
    plot(t_plot,zcircuit(ini_c(kk):sampling_rate:ini_c(kk)+(length(t_plot)*2-1)),'-k','LineWidth',3);
    hold on
    xline(num_tpoints*dt,'-','LineWidth',3);  
    xlabel('t')
    ylabel('z')    

    xlim([0,t_plot(end)])

    set(findall(gcf,'-property','FontSize'),'FontSize',30); 

    pbaspect([1.66 .25 1]) 
end

% Plot error (Figure 1(f))
for i = 1:length(lowest_level)    
    jj = lowest_level(i);

    dt = 0.01;
    t_plot = 0:dt:2;
    num_tpoints = 91; % 1 Lyapunov time.

    y0 = ypredicted_x(jj,kk);
    X0 = [X_real{kk}(1,1), y0, X_real{kk}(1,3)];

    sol_model_figure = RK4(@Lorenz_Generic, X0, t_plot, parameters_model(jj,:));
    X_simx = sol_model_figure(:,1);
    X_simy = sol_model_figure(:,2);            
    X_simz = sol_model_figure(:,3);

    error = abs(X_simx - xcircuit(ini_c(kk):sampling_rate:ini_c(kk)+(length(t_plot)*2-1)))+...
        abs(X_simz - zcircuit(ini_c(kk):sampling_rate:ini_c(kk)+(length(t_plot)*2-1)));

    figure(201);
    semilogy(t_plot,error,'-','LineWidth',3,'Color',colours(i,:));     
    hold on    
    xline(num_tpoints*dt,'-','LineWidth',3);    
    ylabel('|error|')   
    xlabel('t')   

    xlim([0,t_plot(end)])

    pbaspect([1.66 1 1]) 

    set(findall(gcf,'-property','FontSize'),'FontSize',30); 
end