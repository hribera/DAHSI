import numpy as np

def Meas_Funk(SP,f2,xim,xip1m,num_vars,num_params,num_meas,num_tpoints,dt,Rf): 
    ObjFunk_Meas = np.sum(np.square(np.array([SP[0:num_meas]]) - np.array([xim]))) + np.sum(np.square(np.array([SP[num_vars:num_vars+num_meas]]) - np.array([xip1m])))
    
    return ObjFunk_Meas/float(num_tpoints)
    
def Model_Funk(SP,f2,xi,xip1,xip2,params,num_vars,num_params,num_meas,num_tpoints,dt,Rf):    
    ObjFunk_Model = np.sum(Rf*(np.square(np.array([xip2]) - np.array([xi]) - (dt/3.)*(np.array([f2(xi,params)]) + 4.*np.array([f2(xip1,params)]) + np.array([f2(xip2,params)]))) 
                        + np.square(np.array([xip1]) - 0.5*(np.array([xi]) + np.array([xip2])) - (dt/4.)*(np.array([f2(xi,params)]) - np.array([f2(xip2,params)])))))
    return ObjFunk_Model/float(num_tpoints)    
