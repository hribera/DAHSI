clear all
close all

% Plot \lambda vs. action
% Figure 1(f)

% Needs 'parameters_*.mat' file to run. They are
% created in 'main_SaveResults.m'. For this example, we already created 
% this file for the results obtained with DAHSI from the experimental 
% data set.

load('parameters_LorenzSynth_V5_s0p01_04.mat')

dark_grey = [0.4,0.4,0.4];
light_grey = [179,179,179]./255;
blue = [136,204,238]./255;

num_simulations = num_IC*num_lambd;
exponent_action = ceil(log10(min(action(:,end))));
action_threshold = 10^exponent_action;

indices_IC_all = [];
for jj = 1:num_simulations
    if (sum(parameters(jj,terms_off)) == 0) && (all(parameters(jj,terms_on)) == 1)     
        indices_IC_all = [indices_IC_all; jj];
    end
end  

[~,num_params] = size(parameters);

lambd_ind = 8; % \lambda = 0.4
action_lambd = action((lambd_ind-1)*num_IC+1:lambd_ind*num_IC,:);

figure;
for jj = 1:num_simulations
    if action(jj,end) < action_threshold && ismember(jj,indices_IC_all) == 0
        semilogy(lambd_long_vect(jj),action(jj,end),'.-','MarkerSize',50,'Color',dark_grey);
        hold on        
    elseif action(jj,end) > action_threshold && ismember(jj,indices_IC_all) == 0
        semilogy(lambd_long_vect(jj),action(jj,end),'.','MarkerSize',50,'Color',light_grey);
        hold on  
    end
end
for jj = 1:num_simulations
    if action(jj,end) < action_threshold && ismember(jj,indices_IC_all) == 1
        semilogy(lambd_long_vect(jj),action(jj,end),'.','MarkerSize',50,'Color',blue);
        hold on        
    end
end

pbaspect([1.65 1 1])

xlim([lambdini,lambdend])
ylim([min(action_lambd(:,end))*0.5,max(action_lambd(:,end))])

xlabel('\lambda')
ylabel('$\hat{A}(\mathbf{X},\mathbf{p},R_f)$','Interpreter','latex')

set(findall(gcf,'-property','FontSize'),'FontSize',25);

% create smaller axes.
axes('Position',[.56 .4 .3 .3])
box on
for jj = 1:num_simulations
    if action(jj,end) < action_threshold && ismember(jj,indices_IC_all) == 0
        semilogy(lambd_long_vect(jj),action(jj,end),'.-','MarkerSize',50,'Color',dark_grey);
        hold on        
    elseif action(jj,end) > action_threshold && ismember(jj,indices_IC_all) == 0
        semilogy(lambd_long_vect(jj),action(jj,end),'.','MarkerSize',50,'Color',light_grey);
        hold on  
    end
end
for jj = 1:num_simulations
    if action(jj,end) < action_threshold && ismember(jj,indices_IC_all) == 1
        semilogy(lambd_long_vect(jj),action(jj,end),'.','MarkerSize',50,'Color',blue);
        hold on        
    end
end

pbaspect([1.65 1 1])

ylim([min(action_lambd(:,end))*0.9999,min(action_lambd(:,end))*1.001])

set(findall(gcf,'-property','FontSize'),'FontSize',40);