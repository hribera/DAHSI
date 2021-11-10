function dXdt = LorenzSynth(t,X,params)  
    dxdt = params(1)*(X(2)-X(1));
    dydt = X(1)*(params(2)-X(3))-X(2);
    dzdt = X(1)*X(2) - params(3)*X(3);
    
    dXdt = [dxdt, dydt, dzdt];    
end
