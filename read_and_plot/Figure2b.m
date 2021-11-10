clear all
close all

% Figure 2(b).

load('parameters_LorenzSynth_V5_s0p01_04.mat')
load('Paths_Threshold_NoThreshold.mat')

incorrect_colour = [51,34,136]./255;
correct_colour = [136,204,238]./255;

max_beta = 224;

param_evol_right_nosparsity = all_nosparsity(:,4:end);
param_evol_right_sparsity = all_sparsity(:,4:end);
        
ini = 135;
fin = 140;

param_evol_wrong = all_actions((max_beta+1)*6+1:(max_beta+1)*7,4:end);
param_evol_right = all_actions((max_beta+1)*7+1:(max_beta+1)*8,4:end);

figure;
plot([ini:fin],param_evol_right_nosparsity(ini:fin,25),'.-','LineWidth',4,'MarkerSize',40,'Color',[153,153,153]./255);
hold on
plot([ini:fin],param_evol_wrong(ini:fin,25),'x-','LineWidth',4,'MarkerSize',20,'Color',incorrect_colour);
hold on
plot([ini:fin],param_evol_right_sparsity(ini:fin,25),'.-','LineWidth',4,'MarkerSize',40,'Color',correct_colour);
hold on
yline(0.35,'--','LineWidth',4,'Color',incorrect_colour);
hold on
yline(0.4,'--','LineWidth',4,'Color',correct_colour);

xlabel('\beta')
ylabel('parameter p_{3,5} value')
axis square

set(findall(gcf,'-property','FontSize'),'FontSize',30);  