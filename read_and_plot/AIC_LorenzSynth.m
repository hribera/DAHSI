% This code takes the 17 down-selected models and the parameter
% estimation values and creates a .mat file with all the necessary
% information to then plot num. terms vs \Delta AIC/BIC.

clear all
close all

colours = [[51,34,136]./255;...
           [136,204,238]./255;...
           [68,170,153]./255;...
           [17,119,51]./255;...
           [221,204,119]./255;...
           [102,17,0]./255;...
           [204,102,119]./255;...
           [170,68,153]./255];
       
light_grey = [179/255, 179/255, 179/255];

num_vars = 3;
num_meas = 2;
num_tpoints = 30; % 1/4 Lyapunov time.

N = num_tpoints;
dt = 0.01;
tfin = dt*(num_tpoints-1);       
t_1Ly = linspace(0,tfin,num_tpoints);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% code to get model structure for each model.
load('structures_LorenzSynth_V5_s0p01_04.mat');
[num_models, ~] = size(unique_structures);

for jj = 1:num_models
    active_terms(jj) = sum(unique_structures(jj,:));
end

num_q = 30;

% estimated parameter values from VA+IPOPT by doing only PE.
params_models{1} = [-5.0989  -19.7441    1.6563    4.9549   -0.7472   -3.9936];
params_models{2} = [-9.9933   17.3387   16.1428   -1.0012   -0.5765   -2.6667    1.7346];
params_models{3} = [-6.0448   16.4916   18.1795   -4.9496   -0.6061   -2.6667    0.3950    1.6498];
params_models{4} = [-7.2077   19.7636    0.3125   -2.2486    4.6860   -1.7363    4.9185];       
params_models{5} = [-9.9942   17.3073    0.0006   16.1749   -1.0019   -0.5776   -2.6667    1.7312];
params_models{6} = [-10.6387   19.8072    0.0006   13.8197   -0.3575   -0.5047   -2.6667   -0.0644    1.9812];   
params_models{7} = [-9.9959   -8.6519    0.0007  -32.3529   -1.0001    1.1554   -2.6668   -0.0001   -0.8654    0.0000];
params_models{8} = [-8.4267   10.8076   -0.0082   26.9778   -2.5691    0.0010   -0.9250   -2.6668    0.1568    1.0811    -0.0009];
params_models{9} = [-9.9972  -11.5665    4.9682  -24.1993   -0.9986   -0.7166   -0.4968    1.0777   -2.6668   -0.0003   -1.1570    0.4969];
params_models{10} = [4.9046   -7.1127  -19.8000    2.2181    4.8333   -1.0956   -4.4037];
params_models{11} = [-4.9508   -6.3333  -19.7817    2.6032    1.7115    3.8448   -1.0979   -4.7600];
params_models{12} = [-5.0000   -7.2342   19.6657    0.5397   -2.3833    4.9782   -2.2565    4.9848];
params_models{13} = [-0.0069   -9.9947   18.5363    0.0009   15.1017   -1.0015   -0.5393   -2.6668    1.8541];
params_models{14} = [-0.0375   -8.5739   19.8183   -0.0231   14.6677   -2.4220    0.0027   -0.5044   -2.6668    0.1421    1.9825   -0.0025];
params_models{15} = [-0.1342   -8.7158   18.2937   -0.0429   15.8412   -2.2800    0.0048   -0.5465   -0.0106   -2.6668   0.1279    1.8300   -0.0044];
params_models{16} = [-4.9668   -6.6258   19.7986    1.3127    4.9979   -2.2816    4.9968   -2.9836    4.9978];
params_models{17} = [-0.0284   -8.7160   17.8660   -0.0430   -0.0136   16.2204   -2.2797    0.0049   -0.5596   -2.6668   0.1279    1.7872   -0.0044];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% code to get real data.
% put it into cells of size {num. ini. conditions}(num_tpoints x num_vars).
% second column is empty because there is no y observation.
% randomly select the initial points.
% output -> X_real{.}(.,.).

%%% real data.
num_datapoints_realdata = 13801;

filename = 'datax_LorenzSynth_AIC.dat';
delimiterIn = ' ';
headerlinesIn = 0;
xsol_Synth = importdata(filename,delimiterIn,headerlinesIn);

filename = 'dataz_LorenzSynth_AIC.dat';
delimiterIn = ' ';
headerlinesIn = 0;
zsol_Synth = importdata(filename,delimiterIn,headerlinesIn);

% number of time segments (including the ones used to perform model selection).
S = 1000;

% time series used for selecting the models. we will not use them for
% validation.
affected_time_series = 1:1:21;  

for kk = 1:S
    X_real{kk} = zeros(num_tpoints,num_vars);

    ini_c(kk) = (kk-1)*N - (kk-2) + 8;
    fin_c(kk) = ini_c(kk) + N - 1;

    X_real{kk}(:,1) = xsol_Synth(ini_c(kk):fin_c(kk));
    X_real{kk}(:,3) = zsol_Synth(ini_c(kk):fin_c(kk));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 8th order discretisation to obtain y0 for each time series and each model.    
ypredicted_x = zeros(num_models,S);

parameters_model = zeros(num_models,num_q);

for jj = 1:num_models
    pp = 1;
    for qq = 1:num_q
        if unique_structures(jj,qq) ~= 0
            parameters_model(jj,qq) = params_models{jj}(pp);
            pp = pp + 1;
        end
    end
end

for jj = 1:num_models
    for kk = 1:S
        ini = ini_c(kk);

        xkm4 = xsol_Synth(ini-4);
        xkm3 = xsol_Synth(ini-3);
        xkm2 = xsol_Synth(ini-2);
        xkm1 = xsol_Synth(ini-1);
        xk = xsol_Synth(ini);                 % this is ini, the one we want for y!
        xkp1 = xsol_Synth(ini+1);
        xkp2 = xsol_Synth(ini+2);
        xkp3 = xsol_Synth(ini+3);
        xkp4 = xsol_Synth(ini+4);
        zk = zsol_Synth(ini);                 % this is ini, the one we want for y!

        chunckeq = sum(parameters_model(jj,1:10).*[1,xk,0,zk,xk*xk,0,xk*zk,0,0,zk*zk]);

        % 8th order.
        ypredicted_x(jj,kk) = (3*xkm4-32*xkm3+168*xkm2-672*xkm1+672*xkp1-168*xkp2+32*xkp3-3*xkp4-840*dt*chunckeq)/(840*dt*parameters_model(jj,3));
    end   
end    

ind_all_models = 1:num_models;

lowest_level = [1,2,5,13,7,8,14,15];
other_level = [3,4,6,10,11,12,9,16,17];

sampling_rate = 1;

save('AIC_Plot_LorenzSynth.mat','ypredicted_x','X_real','S','parameters_model','affected_time_series',...
     'num_vars','num_meas','num_tpoints','sampling_rate','N','dt','tfin','t_1Ly','num_models','active_terms',...
     'xsol_Synth','zsol_Synth','colours','ind_all_models','lowest_level','other_level','ini_c','light_grey');
