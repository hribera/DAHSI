function dXdt = LorenzSynth_Recovered(t,X,params)  
    dxdt = params(1)*X(1) + params(2)*X(2);
    dydt = params(3)*X(1) + params(4)*X(2) + params(5)*X(1)*X(3); 
    dzdt = params(6)*X(3) + params(7)*X(1)*X(2);
    
    dXdt = [dxdt, dydt, dzdt];    
end