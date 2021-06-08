clear all

load('Variables_Plotting_Circuit.mat')

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

% AIC Figure.
figure;
for i = 1:length(grey_models)
    jj = grey_models(i);
    plot(S_ini:S_real,AIC_all(jj,S_ini:S_real),'LineWidth',3,'Color',light_grey)        
    hold on
end
for i = 1:length(lowest_level)
    jj = lowest_level(i);
    plot(S_ini:S_real,AIC_all(jj,S_ini:S_real),'LineWidth',3,'Color',colours(i,:))
    hold on
end

xlim([S_ini,S_max])
ylim([0,30])
box on
xlabel('S')
ylabel('\DeltaAIC')

set(findall(gcf,'-property','FontSize'),'FontSize',30);

% BIC Figure.
figure;
for i = 1:length(grey_models)
    jj = grey_models(i);
    plot(S_ini:S_real,BIC_all(jj,S_ini:S_real),'LineWidth',3,'Color',light_grey)        
    hold on
end
for i = 1:length(lowest_level)
    jj = lowest_level(i);
    plot(S_ini:S_real,BIC_all(jj,S_ini:S_real),'LineWidth',3,'Color',colours(i,:))
    hold on
end

xlim([S_ini,S_max])
ylim([0,30])
box on
xlabel('S')
ylabel('\DeltaBIC')

set(findall(gcf,'-property','FontSize'),'FontSize',30);

save('AIC_BIC_25models.mat','AIC_all','BIC_all','lowest_level','grey_models','S_ini','S_real','light_grey',...
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
