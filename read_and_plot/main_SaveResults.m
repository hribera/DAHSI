clear all
close all

% This currently reads the output files uploaded with the code package
% found in ../Example_LorenzSynth/outputfiles.

% It creates a file 'parametesr_LorenzSynth.mat' with all the relevant
% outputs of reading the DAHSI produced files, and a file
% 'structures_LorenzSynth.mat' with the unique model structures found.

% These files can later be used in 'main_PlotOutputfiles.m' to create 
% relevant plots from the results of the algorithm.

% We read the result files.
input_file_extension = 'LorenzSynth';
       
% Relevant values from the problem we have solved using DAHSI.
num_IC = 100;
num_vars = 3;
num_meas = 2;
num_params = 30;
beta_input = 256;
beta_want = 224;
lambdini = 0.3;
lambdend = 0.5;
lambdstep = 0.05;

Read_ResultFiles(input_file_extension,num_IC,num_vars,num_meas,...
                          num_params,beta_input,beta_want,lambdini,lambdend,lambdstep);

% We load the relevant variables of the results.
file_parameters = sprintf('parameters_%s.mat',input_file_extension);
load(file_parameters)

%
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
