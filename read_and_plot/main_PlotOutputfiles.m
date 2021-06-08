clear all
close all

% This file creates relevant plots from the results of the algorithm.
% * \lambda vs. active terms.
% * \beta vs action, for a given \lambda.
% * \lambda vs. action.

% Needs 'parameters_*.mat' and 'structures_*.mat' files to run. They are
% created in 'main_SaveResults.m'. For this example, we already created 
% these files for the results obtained with DAHSI from the experimental 
% data set.

load('parameters_Circuit.mat')
load('structures_Circuit.mat')

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
% Figure 3(d).
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

% Plot \beta vs action, for a given \lambda (in this case, = 3.9).
% Figure 3(b).
lambd_ind = 15;

action_lambd = action((lambd_ind-1)*num_IC+1:lambd_ind*num_IC,:);

parameters_lambd = parameters((lambd_ind-1)*num_IC+1:lambd_ind*num_IC,:);
activeterms_lambd = active_terms((lambd_ind-1)*num_IC+1:lambd_ind*num_IC);

figure;
subplot(1,2,1)
for jj = 1:num_IC
    semilogy(0:max_beta,action_lambd(jj,:),'.-','LineWidth',2,'MarkerSize',15,'Color',light_grey);
    hold on  
    if action_lambd(jj,end) < action_threshold
        semilogy(0:max_beta,action_lambd(jj,:),'.-','LineWidth',2,'MarkerSize',15,'Color',dark_grey);
        hold on        
    end
end  

indices_IC = [];
for jj = 1:num_IC
    if (sum(parameters_lambd(jj,terms_off)) == 0) && (all(parameters_lambd(jj,terms_on)) == 1)     
        indices_IC = [indices_IC; jj];
        if action_lambd(jj,end) < action_threshold
        	semilogy(0:max_beta,action_lambd(jj,:),'.-','LineWidth',2,'MarkerSize',15,'Color',blue);
            hold on          
        end
    end
end  

xlim([0,max_beta-1])
% ylim([min(action_lambd(:,end))*0.5,max(action_lambd(:,end))*1.5])

xlabel('\beta')
ylabel('$\hat{A}(\mathbf{X},\mathbf{p},R_f)$','Interpreter','latex')

axis square

set(findall(gcf,'-property','FontSize'),'FontSize',40); 

% Plot active terms vs. end action values.
subplot(1,2,2)
for jj = 1:num_IC
    if action_lambd(jj,end) < action_threshold && ismember(jj,indices_IC) == 0
        semilogy(activeterms_lambd(jj),action_lambd(jj,end),'.-','MarkerSize',50,'Color',dark_grey);
        hold on        
    elseif action_lambd(jj,end) > action_threshold && ismember(jj,indices_IC) == 0
        semilogy(activeterms_lambd(jj),action_lambd(jj,end),'.','MarkerSize',50,'Color',light_grey);
        hold on
    else
        semilogy(activeterms_lambd(jj),action_lambd(jj,end),'.','MarkerSize',50,'Color',blue);
        hold on        
    end
end

xlim([min(activeterms_lambd),max(activeterms_lambd)])
ylim([min(action_lambd(:,end))*0.5,max(action_lambd(:,end))*1.5])

xlabel('num. active terms')
ylabel('$\hat{A}(\mathbf{X},\mathbf{p},R_f)$','Interpreter','latex')

axis square

set(findall(gcf,'-property','FontSize'),'FontSize',40);

% create smaller axes.
axes('Position',[.65 .26 .3 .3])
box on
for jj = 1:num_IC
    if action_lambd(jj,end) < action_threshold && ismember(jj,indices_IC) == 0
        semilogy(activeterms_lambd(jj),action_lambd(jj,end),'.-','MarkerSize',50,'Color',dark_grey);
        hold on        
    elseif action_lambd(jj,end) > action_threshold && ismember(jj,indices_IC) == 0
        semilogy(activeterms_lambd(jj),action_lambd(jj,end),'.','MarkerSize',50,'Color',light_grey);
        hold on
    else
        semilogy(activeterms_lambd(jj),action_lambd(jj,end),'.','MarkerSize',50,'Color',blue);
        hold on        
    end
end
ylim([min(action_lambd(:,end))*0.75,min(action_lambd(:,end))*1.5])

axis square

set(findall(gcf,'-property','FontSize'),'FontSize',36);

% Plot \lambda vs. action
% Figure 1(c)

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
axes('Position',[.56 .55 .3 .3])
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

ylim([min(action_lambd(:,end))*0.75,min(action_lambd(:,end))*1.5])

set(findall(gcf,'-property','FontSize'),'FontSize',40);
