clear all

% Figure 1(g).

load('AIC_Plot_LorenzSynth.mat')

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

%%
grey_models = 1:num_models;
grey_models(lowest_level) = [];

save('AIC_BIC_LorenzSynth.mat','AIC_all','BIC_all','lowest_level','grey_models','S_ini','S_real','light_grey',...
     'S_max','active_terms','colours')

%%

figure;
for i = 1:num_models
    i
    if AIC_all(i,end) == 0
        plot(active_terms(i),AIC_all(i,end),'o',...
        'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
        hold on
        plot(active_terms(i),AIC_all(i,end),'o',...
        'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',[136,204,238]./255);  
        hold on
    else
        if AIC_all(i,end) <= 10
            plot(active_terms(i),AIC_all(i,end),'o',...
            'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
            hold on
            plot(active_terms(i),AIC_all(i,end),'o',...
            'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',[0.4,0.4,0.4]);     
            hold on
        else
            plot(active_terms(i),AIC_all(i,end),'o',...
            'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
            hold on
            plot(active_terms(i),AIC_all(i,end),'o',...
            'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',light_grey);
            hold on
        end
    end
end
xlim([5,14])    
ylim([0,15])    

pbaspect([1.4 1 1])    

xlabel('active terms')
ylabel('\DeltaAIC')   

% create smaller axes in top right, and plot on it
axes('Position',[.18 .5 .4 .4])
box on
for i = 1:num_models
    i
    if AIC_all(i,end) == 0
        plot(active_terms(i),AIC_all(i,end),'o',...
        'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
        hold on
        plot(active_terms(i),AIC_all(i,end),'o',...
        'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',[136,204,238]./255);  
        hold on
    else
        if AIC_all(i,end) <= 10
            plot(active_terms(i),AIC_all(i,end),'o',...
            'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
            hold on
            plot(active_terms(i),AIC_all(i,end),'o',...
            'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',[0.4,0.4,0.4]);     
            hold on
        else
            plot(active_terms(i),AIC_all(i,end),'o',...
            'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
            hold on
            plot(active_terms(i),AIC_all(i,end),'o',...
            'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',light_grey);
            hold on
        end
    end
end
xlim([5,14])    
ylim([0,1e4])  

xticks([6,8,10,12,14])
yticks([0,2.5e3,5e3,7.5e3,1e4])

pbaspect([1 1 1])    

set(findall(gcf,'-property','FontSize'),'FontSize',40);  
