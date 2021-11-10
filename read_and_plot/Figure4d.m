clear all
close all

% Figure 4(d)

load('AIC_Plot_LorenzCircuit.mat')

% initial point given by kk
kk = 20;

for i = 1:length(lowest_level)    
    jj = lowest_level(i);

    dt = 0.01;
    t_plot = 0:dt:2;
    num_tpoints = 91;

    y0 = ypredicted_x(jj,kk);
    X0 = [X_real{kk}(1,1), y0, X_real{kk}(1,3)];

    sol_model_figure = RK4(@GenericModel, X0, t_plot, parameters_model(jj,:));
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

    sol_model_figure = RK4(@GenericModel, X0, t_plot, parameters_model(jj,:));
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

clear all

load('AIC_Plot_LorenzCircuit.mat')

% number of time series.
S_ini = 15;
S_max = S-length(affected_time_series);

% remove the time-segments that are used to run the DAHSI algorithm.
all_time_segments = 1:S;
all_time_segments(affected_time_series) = [];

for s = S_ini:S_max
    S_real = s;
    s        

    ind_ts = randperm(length(all_time_segments));
    S_sampled = all_time_segments(ind_ts);
    for kk = 1:s
        X_real_picked{kk}(:,1) = X_real{S_sampled(kk)}(:,1);
        X_real_picked{kk}(:,3) = X_real{S_sampled(kk)}(:,3);        
        ypredicted_x_picked(:,kk) = ypredicted_x(:,S_sampled(kk));
    end

    % model loop
    for jj = 1:num_models        
        num_params = active_terms(jj);

        % time-segment loop
        for kk = 1:s
            y0 = ypredicted_x_picked(jj,kk);

            X0 = [X_real_picked{kk}(1,1), y0, X_real_picked{kk}(1,3)];

            sol_model = RK4(@GenericModel, X0, t_1Ly, parameters_model(jj,:));
            X_model{jj}{kk}(:,1) = sol_model(:,1);
            X_model{jj}{kk}(:,2) = sol_model(:,2);            
            X_model{jj}{kk}(:,3) = sol_model(:,3);

            % only use 1/4 of Lyapunov time and do not consider the first 4
            % points as they are used in estmating y_0.
            N_start = 5;
            N_window = num_tpoints-5;
            t_window = N_start:(N_window+N_start-1);

            % calculate E_av.
            sum_1(kk) = sum((X_real_picked{kk}(t_window,1) - X_model{jj}{kk}(t_window,1)).^2);
            sum_2(kk) = sum((X_real_picked{kk}(t_window,3) - X_model{jj}{kk}(t_window,3)).^2);

            sum_squares(kk) = (1/(num_meas*N_window))*(sum_1(kk)+sum_2(kk));          
        end
        
        % calculte AIC.
        AIC(jj) = S_real*log(sum(sum_squares)/S_real) + 2*num_params;
        AIC_c(jj) = AIC(jj);
        
        % calculate BIC.
        BIC(jj) = S_real*log(sum(sum_squares)/S_real) + num_params*log(S_real);
        BIC_c(jj) = BIC(jj);
    end

    AIC_Final = AIC_c - min(AIC_c);
    AIC_all(:,kk) = AIC_Final;

    BIC_Final = BIC_c - min(BIC_c);
    BIC_all(:,kk) = BIC_Final;        

    clear AIC
    clear AIC_c
    clear BIC
    clear BIC_c       
    clear AIC_Final                 
    clear BIC_Final                 
end

grey_models = 1:num_models;
grey_models(lowest_level) = [];

save('AIC_BIC_LorenzCircuit.mat','AIC_all','BIC_all','lowest_level','grey_models','S_ini','S_real','light_grey',...
     'S_max','active_terms','colours')

%%

figure;    
for i = 1:length(grey_models)
    jj = grey_models(i);
    plot(active_terms(jj),AIC_all(jj,end),'o',...
        'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
    hold on
    plot(active_terms(jj),AIC_all(jj,end),'o',...
    'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',[0.4,0.4,0.4]);    
end
for i = 1:length(lowest_level)
    jj = lowest_level(i);
    plot(active_terms(jj),AIC_all(jj,end),'o',...
        'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
    hold on
    plot(active_terms(jj),AIC_all(jj,end),'o',...
        'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',colours(i,:));
end
xlim([5,13])    
ylim([0,130])    

pbaspect([1.277 1 1])    

xlabel('active terms')
ylabel('\DeltaAIC')    

set(findall(gcf,'-property','FontSize'),'FontSize',40);  
