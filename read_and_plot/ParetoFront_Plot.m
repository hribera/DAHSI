clear all
close all

load('Variables_Plotting_Circuit.mat')

% Find the E_av of each model.
E_av = zeros(1,num_models);

% model loop
for jj = 1:num_models       
    % time series loop
    for kk = 1:S
        % if the time-segment belongs to the data used for model
        % selection, we do not consider it.
        if any(affected_time_series == kk)
            sum_squares(kk) = 0;
        else
            % solve system using jj model.
            % solve it with the right structure via Lorenz_Generic.
            % save it in X_modeljj{.}(.,.).

            y0 = ypredicted_x(jj,kk);

            X0 = [X_real{kk}(1,1), y0, X_real{kk}(1,3)];

            sol_model = RK4(@Lorenz_Generic, X0, t_1Ly, parameters_model(jj,:));
            X_model{jj}{kk}(:,1) = sol_model(:,1);
            X_model{jj}{kk}(:,2) = sol_model(:,2);            
            X_model{jj}{kk}(:,3) = sol_model(:,3);

            N_start = 5;
            N_window = 23-5;
            t_window = N_start:(N_window+N_start-1);

            sum_1(kk) = sum((X_real{kk}(t_window,1) - X_model{jj}{kk}(t_window,1)).^2);
            sum_2(kk) = sum((X_real{kk}(t_window,3) - X_model{jj}{kk}(t_window,3)).^2);

            sum_squares(kk) = (1/(num_meas*N_window))*(sum_1(kk)+sum_2(kk));  
        end
    end

    % calculte \sum E_av.
    E_av(jj) = sum(sum_squares);
end  

%% Plot Pareto front 
% Figure 1(d)
figure;
plot(active_terms(other_level),E_av(other_level),'o',...
    'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
hold on
plot(active_terms(other_level),E_av(other_level),'o',...
    'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',[0.4,0.4,0.4]);
hold on
for i = 1:length(lowest_level)
    plot(active_terms(lowest_level(i)),E_av(lowest_level(i)),'o',...
        'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
    hold on
    plot(active_terms(lowest_level(i)),E_av(lowest_level(i)),'o',...
        'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',colours(i,:));
    hold on
end

pbaspect([1.65 1 1])

xlim([5,13])

xlabel('active terms')
ylabel('E_{av}')

set(findall(gcf,'-property','FontSize'),'FontSize',40);    

% create smaller axes.
axes('Position',[.55 .47 .4 .4])
box on

plot(active_terms(ind_all_models),E_av(ind_all_models),'o',...
    'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
hold on
plot(active_terms(ind_all_models),E_av(ind_all_models),'o',...
    'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',[0.4,0.4,0.4]);
hold on
for i = 1:length(lowest_level)
    semilogy(active_terms(lowest_level(i)),E_av(lowest_level(i)),'o',...
        'MarkerSize',30,'MarkerEdgeColor','black','MarkerFaceColor','black');
    hold on
    semilogy(active_terms(lowest_level(i)),E_av(lowest_level(i)),'o',...
        'MarkerSize',26,'MarkerEdgeColor','none','MarkerFaceColor',colours(i,:));
    hold on
end    

axis square

xlim([3,13])

xlabel('active terms')
ylabel('E_{av}')

set(findall(gcf,'-property','FontSize'),'FontSize',26);       

%% Plot attractors from the models on the Pareto front.
% initial point given by kk
kk = 5;

t_V5 = 0:0.01:100;

for i = 1:7
    jj = lowest_level(i);

    y0 = ypredicted_x(jj,kk);
    X0 = [X_real{kk}(1,1), y0, X_real{kk}(1,3)];

    sol_model_figure = RK4(@Lorenz_Generic, X0, t_V5, parameters_model(jj,:));
    X_simx = sol_model_figure(:,1);
    X_simy = sol_model_figure(:,2);            
    X_simz = sol_model_figure(:,3);

    figure;
    plot3(X_simx,X_simy,X_simz,'-k','LineWidth',2,'Color',colours(i,:));
    xlabel('x')
    ylabel('y')
    zlabel('z')

    axis square
    view([45 25])

    set(findall(gcf,'-property','FontSize'),'FontSize',40); 
end


