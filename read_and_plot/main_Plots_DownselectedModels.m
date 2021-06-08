% Plotting of figures using the experimental data results for the 25
% down-selected models.

% One can modify the scripts that are run in this file to plot figures from
% other results coming from different data.

% Run this file to produce the plots of
    % * Pareto Front.
    % * Manifolds of models identified in the Pareto Front.
    % * The time series of the data used in the algorithm and the time delay
    % embedding of all the points in the experimental data set.
    % * The prediction of the identified models in the Pareto front and their
    % error.
    % * The \Deta AIC/BIC plots as we add more time-segments in the validation and
    % the final \Delta AIC with all the time-segments available.
    
% First we need to define all the variables needed for plotting running
% the following script.
VariablesForPlotting

% The scripts from here on out are used to obtain the plots.
ParetoFront_Plot

ParetoFront_Manifolds_Plot

UsedData_TimeDelay_Embedding_Data_Plot

ModelPrediction_Error_Plot

AIC_BIC_Plot