clear all
close all

load('AIC_Plot_LorenzCircuit.mat')  

% Figure 4(c).
% Plot attractors from the models on the Pareto front.

% initial point given by kk
kk = 5;

t_manifolds = 0:0.01:100;

for i = 1:7
    jj = lowest_level(i);

    y0 = ypredicted_x(jj,kk);
    X0 = [X_real{kk}(1,1), y0, X_real{kk}(1,3)];

    sol_model_figure = RK4(@GenericModel, X0, t_manifolds, parameters_model(jj,:));
    X_simx = sol_model_figure(:,1);
    X_simy = sol_model_figure(:,2);            
    X_simz = sol_model_figure(:,3);

    figure;
    plot3(X_simx,X_simy,X_simz,'-k','LineWidth',2,'Color',colours(i,:));
    xlabel('x')
    ylabel('y')
    zlabel('z')

    axis square
    view([45 25])

    set(findall(gcf,'-property','FontSize'),'FontSize',40); 
end
