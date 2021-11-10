clear all
close all

% Plot \beta vs action, for a given \lambda (in this case, = 3.9).
% Figure 2(a).

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

% xlim([min(activeterms_lambd),max(activeterms_lambd)])
xlim([6,max(activeterms_lambd)])
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
xlim([6,10])
ylim([min(action_lambd(:,end))*0.9999,min(action_lambd(:,end))*1.001])

axis square

set(findall(gcf,'-property','FontSize'),'FontSize',36);
