% RK4
function y = RK4(f,y0,t,params)
    n = length(t);
    y = zeros(n, length(y0));
    y(1,:) = y0;
    for i = 1:(n-1)
        h = t(i+1) - t(i);
        k1 = f(t(i), y(i,:), params);
        k2 = f(t(i) + h / 2., y(i,:) + k1 * h / 2., params);
        k3 = f( t(i) + h / 2., y(i,:) + k2 * h / 2., params);
        k4 = f(t(i) + h, y(i,:) + k3 * h, params);
                        
        y(i+1,:) = y(i,:) + ((h / 6.)*(k1 + 2*k2 + 2*k3 + k4));
    end
end
