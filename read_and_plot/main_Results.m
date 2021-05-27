clear all

% We read the result files.
input_file_extension = 'LorenzSynth_V5_s0p01';
       
num_IC = 500;
num_vars = 3;
num_meas = 2;
num_params = 30;
beta_input = 256;
beta_want = 224;
lambdini = 0.3;
lambdend = 0.6;
lambdstep = 0.05;

Read_ResultFiles(input_file_extension,num_IC,num_vars,num_meas,...
                          num_params,beta_input,beta_want,lambdini,lambdend,lambdstep);

% We load the relevant variables of the results.
file_parameters = sprintf('parameters_%s.mat',input_file_extension);
load(file_parameters)

%%
% Action threshold to down-select models.
indices_lowaction = find(action(:,end) < 8e-4);

[length_lowaction, ~] = size(indices_lowaction);
[~, num_params] = size(parameters);

for i = 1:length_lowaction
    for j = 1:num_params
        if parameters(indices_lowaction(i),j) == 0
            structures(i,j) = 0;
        else
            structures(i,j) = 1;
        end
    end
end

unique_structures = unique(structures,'rows');

file_structures = sprintf('structures_%s.mat',input_file_extension);
save(file_structures,'unique_structures')

%%
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

%% Plot \lambda vs. active terms.
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

%% Plot \beta vs action, for a given \lambda.
% Figure 3(b).
lambd_ind = 3;

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
ylim([min(action_lambd(:,end))*0.5,max(action_lambd(:,end))*1.5])

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

%% Plot \lambda vs. action
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
