#cython: boundscheck=False, wraparound=False, nonecheck=False
import math

from libc.math cimport *
from libc.stdlib cimport malloc, free

from header import *

#from PyIpopt_Funks import *

import time

file_ObjJacHess = open('ObjJacHess.obj', 'rb')

ObjFunk_Meas_eval = pickle.load(file_ObjJacHess)
ObjFunk_Model_eval = pickle.load(file_ObjJacHess)
Jacobian_Meas = pickle.load(file_ObjJacHess)
Jacobian_Model = pickle.load(file_ObjJacHess)
Hessian_Meas = pickle.load(file_ObjJacHess)
Hessian_Model = pickle.load(file_ObjJacHess)
row_final = pickle.load(file_ObjJacHess)
col_final = pickle.load(file_ObjJacHess)
nnzh = pickle.load(file_ObjJacHess)

def eval_f_tricky(x,Rf_C):
    cdef int j, ii
    cdef int T = num_total
    cdef int N = num_tpoints
    cdef int D = num_vars    
    cdef int M = num_meas
    cdef int P = num_params    
    cdef int k

    cdef double Rf
    Rf = Rf_C
    
    cdef double Objective = 0

    cdef double[:] x_C = np.zeros((T))
    cdef double[:, :] data_C = np.zeros((N,M))
    x_C = x
    data_C = data
    
    cdef double[:] Xmeas = np.zeros((M))    
    cdef double[:] Xmeasp1 = np.zeros((M))    
    cdef double[:] Xval = np.zeros((3*D))    
    cdef double[:] Pval = np.zeros((P))   
    
#    Xmeas = np.zeros((M))
#    Xmeasp1 = np.zeros((M))
#    Xval = np.zeros((3*D))
#    Pval = np.zeros((P))
    
    for ii in range(P):
        Pval[ii] = x_C[D*N+ii]

    for j in range(0,N-2,2):
        for ii in range(M):
            Xmeas[ii] = data_C[j,ii]
            Xmeasp1[ii] = data_C[j+1,ii]
            
        k = 3*D - 1
        for ii in range(D):
            Xval[k] = x_C[j*D+k]
            k = k-1
        for ii in range(D):
            Xval[k] = x_C[j*D+k]
            k = k-1
        for ii in range(D):
            Xval[k] = x_C[j*D+k]
            k = k-1  
                        
        # Measurement and Model string.


              
    # Last time point.
    j = N-1
    for ii in range(M):
        Xmeas[ii] =  data_C[j,ii]
        Xmeasp1[ii] = 0

    k = 3*D - 1
    for ii in range(D):
        Xval[k] = 0
        k = k-1
    for ii in range(D):
        Xval[k] = 0
        k = k-1
    for ii in range(D):
        Xval[k] = x_C[j*D+k]
        k = k-1       
       
    # Measurement string.

    
    return np.float64(Objective)
    
def eval_grad_f_tricky(x,Rf_C):
    cdef int j, ii, i, kk
    cdef int T = num_total
    cdef int N = num_tpoints
    cdef int D = num_vars    
    cdef int M = num_meas
    cdef int P = num_params    
    cdef int k
    cdef int i1, i2
    cdef int lim_sq

    cdef double Rf
    Rf = Rf_C
    
    cdef double[:] Xmeas = np.zeros((M))    
    cdef double[:] Xmeasp1 = np.zeros((M))    
    cdef double[:] Xval = np.zeros((3*D))    
    cdef double[:] Pval = np.zeros((P))    
    cdef double[:, :] Jacobian = np.zeros((1,T))    
    cdef double[:, :] str_JacFunk_Meas = np.zeros((1,3*D+P))    
    cdef double[:, :] str_JacFunk_Model = np.zeros((1,3*D+P))    
    
    cdef double[:] x_C = np.zeros((T))
    cdef double[:, :] data_C = np.zeros((N,M))
    x_C = x
    data_C = data
        
    for ii in range(P):
        Pval[ii] = x_C[D*N+ii] 

    for j in range(0,N-2,2):   
        for ii in range(M):
            Xmeas[ii] = data_C[j,ii]
            Xmeasp1[ii] = data_C[j+1,ii]
    
        for kk in range(3*D-1,-1,-1):
            Xval[kk] = x_C[j*D+kk]
                
        # Measurement and Model string.


       
       
        lim_sq = D*j    
        for i2 in range(lim_sq,lim_sq+3*D):
            Jacobian[0,i2] += str_JacFunk_Meas[0,i2-lim_sq]
            Jacobian[0,i2] += str_JacFunk_Model[0,i2-lim_sq]     
                
        for i2 in range(N*D,N*D+P):
            Jacobian[0,i2] += str_JacFunk_Meas[0,i2-D*N+3*D]
            Jacobian[0,i2] += str_JacFunk_Model[0,i2-D*N+3*D]    
            
    # Last time point.
    j = N-1
    for ii in range(M):
        Xmeas[ii] = data_C[j,ii]
        Xmeasp1[ii] = 0
        
    k = 3*D - 1
    for ii in range(D):
        Xval[k] = 0
        k = k-1
    for ii in range(D):
        Xval[k] = 0
        k = k-1
    for ii in range(D):
        Xval[k] = x_C[j*D+k]
        k = k-1      
    
    # Measurement string.

        
    lim_sq = D*j    
    for i2 in range(lim_sq,lim_sq+D):
        Jacobian[0,i2] += str_JacFunk_Meas[0,i2-lim_sq]
            
    for i2 in range(N*D,N*D+P):
        Jacobian[0,i2] += str_JacFunk_Meas[0,i2-D*N+3*D]
        
    return np.asarray(Jacobian)

cdef int T = num_total
#cdef double[:, :] Hessian = np.zeros((T,T))
cdef double **Hessian = <double **> malloc(T * sizeof(double *))
for i in range(T):
    Hessian[i] = <double *> malloc(T * sizeof(double))

cdef long[:] row_final_C = np.array(row_final)  
cdef long[:] col_final_C = np.array(col_final)  

def eval_h_tricky(x,lagrange,obj_factor,flag,Rf_C):  
    cdef int j, ii, i, kk, jj
    cdef int N = num_tpoints
    cdef int D = num_vars    
    cdef int M = num_meas
    cdef int P = num_params    
    cdef int k, p
    cdef int lim_sq
    cdef int i1, i2, i_row, i_col
    cdef int nnzh_C = nnzh
    
    cdef double[:] values = np.zeros((nnzh_C))     
    
    cdef double Rf
    Rf = Rf_C
    
    cdef double[:] Xmeas = np.zeros((M))    
    cdef double[:] Xmeasp1 = np.zeros((M))    
    cdef double[:] Xval = np.zeros((3*D))    
    cdef double[:] Pval = np.zeros((P))     
    cdef double[:, :] str_HessFunk_Meas = np.zeros((3*D+P,3*D+P))    
    cdef double[:, :] str_HessFunk_Model = np.zeros((3*D+P,3*D+P))    
    
    cdef double[:] x_C = np.zeros((T))
    cdef double[:, :] data_C = np.zeros((N,M))
    x_C = x
    data_C = data
    
    if flag:
        # Imported them cause you computed them in Build_ObjJacHess.py.
        return (np.array(col_final),np.array(row_final))
    else:
        # Here fill the Hessian.  
        for ii in range(P):
            Pval[ii] = x_C[D*N+ii] 
    
        for j in range(0,N-2,2):   
            for ii in range(M):
                Xmeas[ii] = data_C[j,ii]
                Xmeasp1[ii] = data_C[j+1,ii]
          
            for k in range(3*D-1,-1,-1):
                Xval[k] = x_C[j*D+k]
                    
            # Measurement and Model string.



            lim_sq = D*j    
            for i1 in range(lim_sq,lim_sq+3*D):
                for i2 in range(lim_sq,lim_sq+3*D):
                    if i1 >= i2:
                        Hessian[i1][i2] += str_HessFunk_Meas[i1-lim_sq][i2-lim_sq]
                        Hessian[i1][i2] += str_HessFunk_Model[i1-lim_sq][i2-lim_sq]
                               
            # Last rows of the Hessian are the derivates with respect of the parameters. 
            for i1 in range(D*N,D*N+P,1):
                for i2 in range(lim_sq,lim_sq+3*D):
                    Hessian[i1][i2] += str_HessFunk_Meas[i1-D*N+3*D][i2-lim_sq]
                    Hessian[i1][i2] += str_HessFunk_Model[i1-D*N+3*D][i2-lim_sq]            
                    
            # Last little square matrix is just the derivatives with respect of parameters.
            for i1 in range(N*D,N*D+P):
                for i2 in range(N*D,N*D+P):
                    if i1 >= i2:
                        Hessian[i1][i2] += str_HessFunk_Meas[i1-D*N+3*D][i2-D*N+3*D]
                        Hessian[i1][i2] += str_HessFunk_Model[i1-D*N+3*D][i2-D*N+3*D]            

        # Last time point.
        j = N-1
        for ii in range(M):
            Xmeas[ii] = data_C[j,ii]
            Xmeasp1[ii] = 0
            
        k = 3*D - 1
        for ii in range(D):
            Xval[k] = 0
            k = k-1
        for ii in range(D):
            Xval[k] = 0
            k = k-1
        for ii in range(D):
            Xval[k] = x_C[j*D+k]
            k = k-1                     

        # Measurement string.

        
        lim_sq = D*j    
        for i1 in range(lim_sq,lim_sq+D):
            for i2 in range(lim_sq,lim_sq+D):
                if i1 >= i2:
                    Hessian[i1][i2] += str_HessFunk_Meas[i1-lim_sq][i2-lim_sq]
   
        # Last rows of the Hessian are the derivates with respect of the parameters. 
        for i1 in range(D*N,D*N+P,1):
            for i2 in range(lim_sq,lim_sq+D):
                Hessian[i1][i2] += str_HessFunk_Meas[i1-D*N+3*D-1][i2-lim_sq]
                                        
        # Last little square matrix is just the derivatives with respect of parameters.
        for i1 in range(N*D,N*D+P):
            for i2 in range(N*D,N*D+P):
                if i1 >= i2:
                    Hessian[i1][i2] += str_HessFunk_Meas[i1-D*N+3*D-1][i2-D*N+3*D-1]
            
        for ii in range(nnzh_C):
            values[ii] = Hessian[row_final_C[ii]][col_final_C[ii]]              

        for j in range(0,N-2,2):               
            lim_sq = D*j    
            for i1 in range(lim_sq,lim_sq+3*D):
                for i2 in range(lim_sq,lim_sq+3*D):
                    if i1 >= i2:        
                        Hessian[i1][i2] = 0
                        Hessian[i1][i2] = 0
                               
            # Last rows of the Hessian are the derivates with respect of the parameters. 
            for i1 in range(D*N,D*N+P,1):
                for i2 in range(lim_sq,lim_sq+3*D):
                    Hessian[i1][i2] = 0
                    Hessian[i1][i2] = 0            
                    
            # Last little square matrix is just the derivatives with respect of parameters.
            for i1 in range(N*D,N*D+P):
                for i2 in range(N*D,N*D+P):
                    if i1 >= i2:
                        Hessian[i1][i2] = 0
                        Hessian[i1][i2] = 0            

        # Last time point.
        j = N-1        
        lim_sq = D*j    
        for i1 in range(lim_sq,lim_sq+D):
            for i2 in range(lim_sq,lim_sq+D):
                if i1 >= i2:
                    Hessian[i1][i2] = 0
   
        # Last rows of the Hessian are the derivates with respect of the parameters. 
        for i1 in range(D*N,D*N+P,1):
            for i2 in range(lim_sq,lim_sq+D):
                Hessian[i1][i2] = 0
                                        
        # Last little square matrix is just the derivatives with respect of parameters.
        for i1 in range(N*D,N*D+P):
            for i2 in range(N*D,N*D+P):
                if i1 >= i2:
                    Hessian[i1][i2] = 0
                
#        time_then = time.time() - time_now        

#        print "Time spend in the only loop in Python is %f seconds." %time_then           
        
        return np.asarray(obj_factor*np.asarray(values))