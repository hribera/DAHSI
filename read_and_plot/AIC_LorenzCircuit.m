% This code takes the 25 down-selected models and the parameter
% estimation values and creates a .mat file with all the necessary
% information to then plot num. terms vs \Delta AIC/BIC.

clear all
close all

colours = [[51,34,136]./255;...
           [136,204,238]./255;...
           [68,170,153]./255;...
           [17,119,51]./255;...
           [221,204,119]./255;...
           [204,102,119]./255;...
           [170,68,153]./255];
       
light_grey = [179/255, 179/255, 179/255];

num_vars = 3;
num_meas = 2;
num_tpoints = 23; % 1/4 Lyapunov time.

sampling_rate = 2;
N = sampling_rate*num_tpoints;
dt = sampling_rate/(12.5e6)/(1.6e-5);
tfin = dt*(num_tpoints-1);       
t_1Ly = linspace(0,tfin,num_tpoints);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% code to get model structure for each model.
load('structures_Circuit.mat');
[num_models, ~] = size(unique_structures);

for jj = 1:num_models
    active_terms(jj) = sum(unique_structures(jj,:));
end

num_q = 30;

% estimated parameter values from VA+IPOPT by doing only PE.
params_models{1} = [-16.5556   19.8000   23.2613   -6.3345   -3.6646    5.1948];
params_models{2} = [-16.9554   18.7853   24.3535    0.2580   -6.7054   -3.6835    4.8273];
params_models{3} = [-16.2109   19.9977   -0.0521   23.4447   -0.2932   -6.3088   -3.6329    5.3126];
params_models{4} = [-0.7881  -16.4682   19.7739   23.1673   -6.3112   -3.6709    5.2162];       
params_models{5} = [-0.8112  -16.4666   19.8120    0.0276   23.0763   -6.2868   -3.6736    5.2315];
params_models{6} = [-0.6794  -16.8906   19.7389    0.0073   -0.0747   22.9337    0.2749   -6.3229   -3.6943    5.1095];   
params_models{7} = [0.0111   19.8032   59.4008  -19.5641];
params_models{8} = [0.9100   19.8000  -59.3999   18.8725   -2.6309];
params_models{9} = [-2.0115   19.8032   59.4009    2.0495  -19.6324];
params_models{10} = [6.6886    0.0116  -19.8026  -59.4008   19.5640];
params_models{11} = [10.2710  -19.8011  -49.0725   -9.9118   17.8327   -0.0076];
params_models{12} = [-0.4848  -20.0000  -10.0000  -60.0000   -0.0581   19.1820];
params_models{13} = [-0.2454    0.0162  -10.7402  -22.9399    6.0010   -9.9019];
params_models{14} = [-16.6479   19.7803   -0.0084   23.4401   -6.3838   -3.6594    5.1523];
params_models{15} = [-0.0274  -10.6705   -0.0593  -23.9730   -0.1290    6.2266  -10.0000];
params_models{16} = [6.1026    0.0155   -9.9796   -1.6651  -22.8772    6.0230  -10.0000];
params_models{17} = [-16.3981   19.2983   -0.0942   23.6137   -6.4330   -3.6782    5.1204    0.0206];
params_models{18} = [ 6.9498   -0.0398   10.2436   -1.8784   23.0599   -0.1801   -6.0468   10.0000];
params_models{19} = [-16.5603   16.7514    0.1486   27.3789   -0.0922   -7.4621   -3.6660    4.3951    0.0883];
params_models{20} = [-1.1832  -16.5234   19.8110    0.0932   23.1527   -6.3075   -3.6696    5.2099   -0.0117];
params_models{21} = [6.7055   -0.0213  -10.2346   -1.8167   -0.1080  -22.9626   -0.1516    6.0243  -10.0000];
params_models{22} = [-17.0172   19.9884    0.1596   22.6028    0.3346   -0.0906   -6.2507   -3.6954    5.1412    0.0903];
params_models{23} = [-0.0627  -16.5630   14.8924    0.1533   30.8024   -0.0902   -8.3950   -3.6659    3.9066    0.0852];
params_models{24} = [-0.2514  -17.0582   19.9840    0.1833   22.6017    0.3567   -0.0843   -6.2561   -3.6966    5.1292    0.0791];
params_models{25} = [-2.4053  -17.0627  19.9862    1.4595   0.7892  22.6061    0.3298   -0.3647    -6.2691   -3.6941   5.1326    0.2900];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% code to get real data.
% put it into cells of size {num. ini. conditions}(num_tpoints x num_vars).
% second column is empty because there is no y observation.
% randomly select the initial points.
% output -> X_real{.}(.,.).

%%% real data.
num_datapoints_realdata = 65537;

fileID = fopen('circuit_x.txt','r');
xcircuit = textscan(fileID, '%f', num_datapoints_realdata, 'CommentStyle', '#'); 
xcircuit = cell2mat(xcircuit);

fileID = fopen('circuit_z.txt','r');
zcircuit = textscan(fileID, '%f', num_datapoints_realdata, 'CommentStyle', '#'); 
zcircuit = cell2mat(zcircuit);

% number of time segments (including the ones used to perform model selection).
S = 1106;

% time series used for selecting the models. we will not use them for
% validation.
affected_time_series = 68:1:90;  

for kk = 1:S
    X_real{kk} = zeros(num_tpoints,num_vars);

    ini_c(kk) = (kk-1)*N - (kk-2) + 8;
    fin_c(kk) = ini_c(kk) + N - 1;

    X_real{kk}(:,1) = xcircuit(ini_c(kk):sampling_rate:fin_c(kk));
    X_real{kk}(:,3) = zcircuit(ini_c(kk):sampling_rate:fin_c(kk));
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

        xkm4 = xcircuit(ini-4*sampling_rate);
        xkm3 = xcircuit(ini-3*sampling_rate);
        xkm2 = xcircuit(ini-2*sampling_rate);
        xkm1 = xcircuit(ini-sampling_rate);
        xk = xcircuit(ini);                 % this is ini, the one we want for y!
        xkp1 = xcircuit(ini+sampling_rate);
        xkp2 = xcircuit(ini+2*sampling_rate);
        xkp3 = xcircuit(ini+3*sampling_rate);
        xkp4 = xcircuit(ini+4*sampling_rate);
        zk = zcircuit(ini);                 % this is ini, the one we want for y!

        chunckeq = sum(parameters_model(jj,1:10).*[1,xk,0,zk,xk*xk,0,xk*zk,0,0,zk*zk]);

        % 8th order.
        ypredicted_x(jj,kk) = (3*xkm4-32*xkm3+168*xkm2-672*xkm1+672*xkp1-168*xkp2+32*xkp3-3*xkp4-840*dt*chunckeq)/(840*dt*parameters_model(jj,3));
    end   
end    

ind_all_models = 1:num_models;

lowest_level = [1,2,5,19,22,24,25];
other_level = [3,4,14,17,20,6,23];

save('AIC_Plot_LorenzCircuit.mat','ypredicted_x','X_real','S','parameters_model','affected_time_series',...
     'num_vars','num_meas','num_tpoints','sampling_rate','N','dt','tfin','t_1Ly','num_models','active_terms',...
     'xcircuit','zcircuit','colours','ind_all_models','lowest_level','other_level','ini_c','light_grey');
