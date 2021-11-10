clear all
close all

% Figure 2(c)

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

% Plot \lambda vs. active terms.
% Figure 2(c).
[action_unique_all,IA,~] = unique(action,'rows');

[total_unique_all,~] = size(action_unique_all);

figure;
for jj = 1:num_simulations
    if action(jj,end) < action_threshold && ismember(jj,indices_IC_all) == 0
        plot(lambd_long_vect(jj),active_terms(jj),'.-','MarkerSize',60,'Color',dark_grey);
        hold on        
    elseif action(jj,end) > action_threshold && ismember(jj,indices_IC_all) == 0
        plot(lambd_long_vect(jj),active_terms(jj),'.','MarkerSize',60,'Color',light_grey);
        hold on
    else
        plot(lambd_long_vect(jj),active_terms(jj),'.','MarkerSize',60,'Color',blue);
        hold on        
    end
end

xlim([lambdini,lambdend])
ylim([0,num_params])

xlabel('\lambda')
ylabel('num. active terms')

axis square

set(findall(gcf,'-property','FontSize'),'FontSize',40);
