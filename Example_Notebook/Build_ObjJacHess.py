###############################################################################
# This file calculates the Objective function, its Jacobian and Hessian for a
# general time point and saves them as strings.
###############################################################################

from header import *
import time
import sys
from sympy import symbols

###############################################################################

time_ini = time.time()

# Create all the variables and parameter names needed for the calculations.

# Frist we create an empty array of the right size.
# The total number of variables in the generic objective function is 3*num_vars+num_params+2*num_meas.
SP = [None]*(3*num_vars+num_params+2*num_meas)

# Then we fill it with the variable names. Variable names are varnameK
# K = i corresponds to varname_{i}
# K = ip1 corresponds to varname_{i+1}
# K = ip2 corresponds to varname_{i+2}
# K = im corresponds to measured varname_{i}
# K = ip1m corresponds to measured varname_{i+1}
k = 0
for i in range(num_vars):
    SP[k] = sym.var(Input1[1+i]+'i')
    k = k+1
for i in range(num_vars):
    SP[k] = sym.var(Input1[1+i]+'ip1')
    k = k+1
for i in range(num_vars):
    SP[k] = sym.var(Input1[1+i]+'ip2')
    k = k+1
        
for i in range(num_meas):
    SP[k] = sym.var(Input1[1+i]+'im')
    k = k+1
for i in range(num_meas):
    SP[k] = sym.var(Input1[1+i]+'ip1m')
    k = k+1
    
# The parametres are given the name as in the input file.
for i in range(num_params):
    SP[-num_params+i] = sym.var(Input1[i+1+num_vars])

# We convert SP from list to tuple.
SP = tuple(SP)

###############################################################################
### Calculate the objective function. #########################################
###############################################################################

print('\nDefining the objective function...')

time_ini_Obj = time.time()

# Read equations.
# The function f reads the equations in the input file. 
# The function f1 converts the equations from strings in the input file to a numpy function.
# Running f1 returns a function which has state variables and parameter values as inputs.
# f2 is the final version we use. 
# It is a function in which you give as input the state variables and parameter values and it returns just a number.
def f1(expression):
    variables = '['+','.join(map(str, Input1[1:1+num_vars]))+']'
    params = '['+','.join(map(str,Input1[1+num_vars:1+num_vars+num_params])) + ']'
    funcstr='''\
def f(k,p):
    {states} = k
    {parameter} = p
    return {e}
    '''.format(states = variables,parameter = params,e=expression)
    exec(funcstr,globals())
    return f
f2 = f1('['+','.join(map(str,Input1[1+num_vars+num_params:1+2*num_vars+num_params:])) + ']')

# We collect all variables at different time points in the same variable.
# For example, if we have three variables x, y and z, xi = (x_{i}, y_{i}, z_{i}), and 
# xip1 = (x_{i+1}, y_{i+1}, z_{i+1}).
i = 0
xi = SP[0:num_vars]
xip1 = SP[num_vars:2*num_vars]
xip2 = SP[2*num_vars:3*num_vars]
xim = SP[3*num_vars:3*num_vars+num_meas]
xip1m = SP[3*num_vars+num_meas:3*num_vars+2*num_meas]

# In this one all parameters are collected.
params = SP[-num_params:]

# We define the model enforcement term as a symbolic variable.
r = sym.var('Rf')

# Here we define the objective function. We divide it in two parts: the measurement part and the model part.
# The functions for the measured and model part are in Obj_Funks.py
ObjFunk_Meas = Meas_Funk(SP,f2,xim,xip1m,num_vars,num_params,num_meas,num_tpoints,dt,Rf)
ObjFunk_Model = Model_Funk(SP,f2,xi,xip1,xip2,params,num_vars,num_params,num_meas,num_tpoints,dt,Rf)

#ObjFunk_Meas = sym.simplify(ObjFunk_Meas)                   
#ObjFunk_Model = sym.simplify(ObjFunk_Model)                   
                   
ObjFunk_Meas_eval = ""
ObjFunk_Model_eval = ""

auxiliar_Obj_Meas = str(ObjFunk_Meas) 
auxiliar_Obj_Model = str(ObjFunk_Model)
 
# Substitute.
for ii in range(num_meas):
    auxiliar_Obj_Meas = auxiliar_Obj_Meas.replace("%s" %SP[-num_params - 2*num_meas + ii], "Xmeas[%d]" %ii)            
    auxiliar_Obj_Model = auxiliar_Obj_Model.replace("%s" %SP[-num_params - 2*num_meas + ii], "Xmeas[%d]" %ii)            
    auxiliar_Obj_Meas = auxiliar_Obj_Meas.replace("%s" %SP[-num_params - 2*num_meas + ii + num_meas], "Xmeasp1[%d]" %ii)   
    auxiliar_Obj_Model = auxiliar_Obj_Model.replace("%s" %SP[-num_params - 2*num_meas + ii + num_meas], "Xmeasp1[%d]" %ii)            

k = 3*num_vars - 1
for ii in range(num_vars):
    auxiliar_Obj_Meas = auxiliar_Obj_Meas.replace("%s" %SP[k], "Xval[%d]" %(k))
    auxiliar_Obj_Model = auxiliar_Obj_Model.replace("%s" %SP[k], "Xval[%d]" %(k))
    k = k-1
for ii in range(num_vars):
    auxiliar_Obj_Meas = auxiliar_Obj_Meas.replace("%s" %SP[k], "Xval[%d]" %(k))
    auxiliar_Obj_Model = auxiliar_Obj_Model.replace("%s" %SP[k], "Xval[%d]" %(k))
    k = k-1
for ii in range(num_vars):
    auxiliar_Obj_Meas = auxiliar_Obj_Meas.replace("%s" %SP[k], "Xval[%d]" %(k))
    auxiliar_Obj_Model = auxiliar_Obj_Model.replace("%s" %SP[k], "Xval[%d]" %(k))
    k = k-1 
for ii in range(num_params):
    auxiliar_Obj_Meas = auxiliar_Obj_Meas.replace("%s" %SP[-num_params+ii], "Pval[%d]" %(ii))
    auxiliar_Obj_Model = auxiliar_Obj_Model.replace("%s" %SP[-num_params+ii], "Pval[%d]" %(ii))
        
ObjFunk_Meas_eval += "+ %s" %auxiliar_Obj_Meas
ObjFunk_Model_eval += "+ %s" %auxiliar_Obj_Model

#print ObjFunk_Meas_eval
#print ObjFunk_Model_eval

# Save the Objective function into a file.
file_ObjJacHess = open('ObjJacHess.obj', 'wb')

pickle.dump(ObjFunk_Meas_eval, file_ObjJacHess)
pickle.dump(ObjFunk_Model_eval, file_ObjJacHess)

time_fin_Obj = time.time() - time_ini_Obj

print ("\n\tIt takes %f seconds to create the objective function for a general time point.\n" %(time_fin_Obj))
     
###############################################################################
### Calculate the Jacobian. ###################################################
###############################################################################

print('\nDefining the Jacobian...')

time_ini_Jac = time.time()

# Define the variables with respect which we take the derivative to compute the Jacobian (aka the gradient). 
SP_derivative = SP[0:3*num_vars]+SP[-num_params:]

# Define that number of variables as an integer.
num_total_vars = int(3*num_vars+num_params)

# Compute the Jacobian symbolically. One for the measurement part and one for the model part of the objective function.
JacFunk_Meas = sym.Matrix([ObjFunk_Meas]).jacobian(SP_derivative)
JacFunk_Model = sym.Matrix([ObjFunk_Model]).jacobian(SP_derivative)

#JacFunk_Meas = sym.simplify(JacFunk_Meas)  
#JacFunk_Model = sym.simplify(JacFunk_Model)  

# Prepare the Jacobian structures in which we will save the string.
Jacobian_Meas = np.array([[''] * num_total_vars] * 1, dtype=object)
Jacobian_Model = np.array([[''] * num_total_vars] * 1, dtype=object)

# Substitute.
for i in range(3*num_vars+num_params):
    auxiliar_Jac_Meas = str(JacFunk_Meas[i])
    auxiliar_Jac_Model = str(JacFunk_Model[i])
       
    for ii in range(num_meas):
        auxiliar_Jac_Meas = auxiliar_Jac_Meas.replace("%s" %SP[-num_params - 2*num_meas + ii], "Xmeas[%d]" %ii)            
        auxiliar_Jac_Model = auxiliar_Jac_Model.replace("%s" %SP[-num_params - 2*num_meas + ii], "Xmeas[%d]" %ii)            
        auxiliar_Jac_Meas = auxiliar_Jac_Meas.replace("%s" %SP[-num_params - 2*num_meas + ii + num_meas], "Xmeasp1[%d]" %ii)            
        auxiliar_Jac_Model = auxiliar_Jac_Model.replace("%s" %SP[-num_params - 2*num_meas + ii + num_meas], "Xmeasp1[%d]" %ii)            
    
    k = 3*num_vars - 1
    for ii in range(num_vars):
        auxiliar_Jac_Meas = auxiliar_Jac_Meas.replace("%s" %SP[k], "Xval[%d]" %(k))
        auxiliar_Jac_Model = auxiliar_Jac_Model.replace("%s" %SP[k], "Xval[%d]" %(k))
        k = k-1
    for ii in range(num_vars):
        auxiliar_Jac_Meas = auxiliar_Jac_Meas.replace("%s" %SP[k], "Xval[%d]" %(k))
        auxiliar_Jac_Model = auxiliar_Jac_Model.replace("%s" %SP[k], "Xval[%d]" %(k))
        k = k-1
    for ii in range(num_vars):
        auxiliar_Jac_Meas = auxiliar_Jac_Meas.replace("%s" %SP[k], "Xval[%d]" %(k))
        auxiliar_Jac_Model = auxiliar_Jac_Model.replace("%s" %SP[k], "Xval[%d]" %(k))
        k = k-1  
    for ii in range(num_params):
        auxiliar_Jac_Meas = auxiliar_Jac_Meas.replace("%s" %SP[-num_params+ii], "Pval[%d]" %(ii))
        auxiliar_Jac_Model = auxiliar_Jac_Model.replace("%s" %SP[-num_params+ii], "Pval[%d]" %(ii))
    Jacobian_Meas[0][i] = "%s" %auxiliar_Jac_Meas
    Jacobian_Model[0][i] = "%s" %auxiliar_Jac_Model

#print Jacobian_Meas             
#print Jacobian_Model             

# Save the Jacobian into a file.
pickle.dump(Jacobian_Meas, file_ObjJacHess)
pickle.dump(Jacobian_Model, file_ObjJacHess)

time_fin_Jac = time.time() - time_ini_Jac

print ("\n\tIt takes %f seconds to create the Jacobian for a general time point.\n" %(time_fin_Jac))

###############################################################################
### Calculate the Hessian. ####################################################
###############################################################################

print('\nDefining the Hessian...')

time_ini_Hess = time.time()

HessFunk_Meas = sym.Matrix([JacFunk_Meas]).jacobian(SP_derivative)
HessFunk_Model = sym.Matrix([JacFunk_Model]).jacobian(SP_derivative)

#HessFunk_Meas = sym.simplify(HessFunk_Meas)  
#HessFunk_Model = sym.simplify(HessFunk_Model)  

# Prepare the Hessian structures in which we will save the string.
Hessian_Meas = np.array([[''] * num_total_vars] * num_total_vars, dtype=object)
Hessian_Model = np.array([[''] * num_total_vars] * num_total_vars, dtype=object)

# Substitute.
for i in range(3*num_vars+num_params):
    for j in range(3*num_vars+num_params):       
        auxiliar_Hess_Meas = str(HessFunk_Meas[i,j])
        auxiliar_Hess_Model = str(HessFunk_Model[i,j])
             
        for ii in range(num_meas):
            auxiliar_Hess_Meas = auxiliar_Hess_Meas.replace("%s" %SP[-num_params - 2*num_meas + ii], "Xmeas[%d]" %ii)            
            auxiliar_Hess_Model = auxiliar_Hess_Model.replace("%s" %SP[-num_params - 2*num_meas + ii], "Xmeas[%d]" %ii)            
            auxiliar_Hess_Meas = auxiliar_Hess_Meas.replace("%s" %SP[-num_params - 2*num_meas + ii + num_meas], "Xmeasp1[%d]" %ii)            
            auxiliar_Hess_Model = auxiliar_Hess_Model.replace("%s" %SP[-num_params - 2*num_meas + ii + num_meas], "Xmeasp1[%d]" %ii)            
        
        k = 3*num_vars - 1
        for ii in range(num_vars):
            auxiliar_Hess_Meas = auxiliar_Hess_Meas.replace("%s" %SP[k], "Xval[%d]" %(k))
            auxiliar_Hess_Model = auxiliar_Hess_Model.replace("%s" %SP[k], "Xval[%d]" %(k))
            k = k-1
        for ii in range(num_vars):
            auxiliar_Hess_Meas = auxiliar_Hess_Meas.replace("%s" %SP[k], "Xval[%d]" %(k))
            auxiliar_Hess_Model = auxiliar_Hess_Model.replace("%s" %SP[k], "Xval[%d]" %(k))
            k = k-1
        for ii in range(num_vars):
            auxiliar_Hess_Meas = auxiliar_Hess_Meas.replace("%s" %SP[k], "Xval[%d]" %(k))
            auxiliar_Hess_Model = auxiliar_Hess_Model.replace("%s" %SP[k], "Xval[%d]" %(k))
            k = k-1  
        for ii in range(num_params):
            auxiliar_Hess_Meas = auxiliar_Hess_Meas.replace("%s" %SP[-num_params+ii], "Pval[%d]" %(ii))
            auxiliar_Hess_Model = auxiliar_Hess_Model.replace("%s" %SP[-num_params+ii], "Pval[%d]" %(ii))

        Hessian_Meas[i][j] = "%s" %auxiliar_Hess_Meas
        Hessian_Model[i][j] = "%s" %auxiliar_Hess_Model
               
#print Hessian_Meas
#print Hessian_Model

Hessian = HessFunk_Meas + HessFunk_Model

# Save the Hessian into a file.
pickle.dump(Hessian_Meas, file_ObjJacHess)
pickle.dump(Hessian_Model, file_ObjJacHess)

time_fin_Hess = time.time() - time_ini_Hess

print ("\n\tIt takes %f seconds to create the Hessian for a general time point.\n" %(time_fin_Hess))

Hessian = np.asarray(Hessian)

#row_general,col_general = np.where(Hessian == 0)
#
#row = []
#col = []
#
#for k in range(len(row_general)):
#  if (row_general[k] >= col_general[k]):
#    row.append(row_general[k])
#    col.append(col_general[k])
#    
#Hessian_colormap = np.zeros((num_total_vars,num_total_vars))
#
#for i in range(len(row)):
#    Hessian_colormap[row[i],col[i]] = 1
#
#import matplotlib.pyplot as plt
#
#plt.imshow(Hessian_colormap);
#plt.colorbar()
#plt.show()
#
##sys.exit("yo, what's up???")

# Lastly calculate how many elements are nonzero in the Hessian.
row_general,col_general = np.where(Hessian[0:3*num_vars,0:3*num_vars] == 0)

row = []
col = []

for k in range(len(row_general)):
  if (row_general[k] >= col_general[k]):
    row.append(row_general[k])
    col.append(col_general[k])

for k in range(len(row)):
  i = row[k]
  j = col[k]
  while (i < num_total-num_params) and (j < num_total-num_params):
      i = i + 2*num_vars
      j = j + 2*num_vars
      row.append(i)
      col.append(j)

  del row[-1]
  del col[-1]
 
col_general_p = []
row_general_p = []
row_p = []
col_p = []

for ii in range(num_params):
  del col_general_p
  del row_general_p
  
  col_general_p = np.where(Hessian[-num_params+ii,0:3*num_vars] == 0)

#  print col_general_p
  
  len_col_general_p = np.shape(col_general_p[0])  
  row_general_p = np.zeros(len(col_general_p[0]), dtype=int) + 3*num_vars+ii
  
  for k in range(len_col_general_p[0]):
    if (row_general_p[0] >= col_general_p[0][k]):
      row_p.append(row_general_p[k])
      col_p.append(col_general_p[0][k])
      
for k in range(len(row_p)):
  i = row_p[k]
  j = col_p[k]
  while (j < num_total-num_params):
      j = j + 2*num_vars
      row_p.append(row_p[k])
      col_p.append(j)

  del row_p[-1]
  del col_p[-1]

for i in range(len(row_p)):
  row.append(row_p[i])
  col.append(col_p[i])

row_general,col_general = np.where(Hessian[-num_params::,-num_params::] == 0)

row_general = row_general+num_tpoints*num_vars
col_general = col_general+num_tpoints*num_vars

for k in range(len(row_general)):
  if (row_general[k] >= col_general[k]):
    row.append(row_general[k])
    col.append(col_general[k])

len_zeros = len(row)

if len_zeros > 0:
    tuples_rowcol = list(zip(row,col))
    tuples_rowcol = set(tuples_rowcol)
    row,col = list(zip(*tuples_rowcol))
    tuples_rowcol = list(zip(row,col))

len_zeros = len(row)

row_final = []
col_final = []

for j in range(0,num_tpoints-2,2):
    for i in range(0,3*num_vars,1):
        k = int(1./2*j)
        col = range(((k)*(2*num_vars)),((k)*(2*num_vars)+1)+(i-1)+1,1)
        row_fixed = i+(k)*(2*num_vars)
        
        for ii in range(len(col)):
            row_final.append(row_fixed)
            col_final.append(col[ii])       

for j in range(num_params):
    for i in range(num_total):
        row = num_tpoints*num_vars + j
        col = i
        if row >= col:
            row_final.append(row)
            col_final.append(col)

tuples_rowcol_final = list(zip(row_final,col_final)) 
tuples_rowcol_final = set(tuples_rowcol_final)
row_final,col_final = list(zip(*tuples_rowcol_final))
tuples_rowcol_final = list(zip(row_final,col_final))

for k in range(len_zeros):
    if tuples_rowcol[k] in tuples_rowcol_final:
        tuples_rowcol_final.remove(tuples_rowcol[k])

row_final,col_final = list(zip(*tuples_rowcol_final))
         
nnzh = len(row_final)       

print ("\tThere's a total of %d non-zeros in the full Hessian.\n" %nnzh)

pickle.dump(row_final, file_ObjJacHess)
pickle.dump(col_final, file_ObjJacHess)
pickle.dump(nnzh, file_ObjJacHess)

time_fin = time.time() - time_ini

print ("\nTotal time: %f seconds.\n" %time_fin)

#print Hessian_Model
