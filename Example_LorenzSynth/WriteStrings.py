from header import *
import time
import sys
from sympy import symbols
import pickle
import numpy as np

file_ObjJacHess = open('ObjJacHess.obj', 'rb')

ObjFunk_Meas_eval = pickle.load(file_ObjJacHess)
ObjFunk_Model_eval = pickle.load(file_ObjJacHess)
Jacobian_Meas = pickle.load(file_ObjJacHess)
Jacobian_Model = pickle.load(file_ObjJacHess)
Hessian_Meas = pickle.load(file_ObjJacHess)
Hessian_Model = pickle.load(file_ObjJacHess)

string_Jac_Meas = ""
for i in range(3*num_vars+num_params):
    string_Jac_Meas += "        str_JacFunk_Meas[0,%d] = %s\n" %(i,Jacobian_Meas[0,i])

string_Jac_Model = ""
for i in range(3*num_vars+num_params):
    string_Jac_Model += "        str_JacFunk_Model[0,%d] = %s\n" %(i,Jacobian_Model[0,i])     

string_Jac_Meas_LessIndent = ""
for i in range(3*num_vars+num_params):
    string_Jac_Meas_LessIndent += "    str_JacFunk_Meas[0,%d] = %s\n" %(i,Jacobian_Meas[0,i])

###############################################################################

string_Hess_Meas = ""
for j in range(3*num_vars+num_params):
    for i in range(3*num_vars+num_params):
        string_Hess_Meas += "            str_HessFunk_Meas[%d,%d] = %s\n" %(j,i,Hessian_Meas[j,i])  
string_Hess_Meas += "\n"
        
string_Hess_Model = ""
for j in range(3*num_vars+num_params):
    for i in range(3*num_vars+num_params):
        string_Hess_Model += "            str_HessFunk_Model[%d,%d] = %s\n" %(j,i,Hessian_Model[j,i])          
            
string_Hess_Meas_LessIndent = ""
for j in range(3*num_vars+num_params):
    for i in range(3*num_vars+num_params):
        string_Hess_Meas_LessIndent += "        str_HessFunk_Meas[%d,%d] = %s\n" %(j,i,Hessian_Meas[j,i])  
          
###############################################################################

# Open and read the template file "OneLoopInC_Blank.pyx"
file1 = open("OneLoopInC_Blank.pyx","r") 

# Each line in file gets saved in internal.
internal = file1.readlines()
file1.close()

# We add to the corresponding lines the Model and Measurement strings.
internal[73] = "        Objective += %s\n" %ObjFunk_Meas_eval
internal[74] = "        Objective += %s\n" %ObjFunk_Model_eval
internal[94] = "    Objective += %s\n" %ObjFunk_Meas_eval

internal[137] = "%s" %string_Jac_Meas
internal[139] = "%s" %string_Jac_Model        
internal[168] = "%s" %string_Jac_Meas_LessIndent

internal[233] = "%s" %string_Hess_Meas
internal[235] = "%s" %string_Hess_Model        
internal[274] = "%s" %string_Hess_Meas_LessIndent
       
newinternal = ''.join(internal)

# Create the new file which has the right strings for the Model and Measurement parts.
file2= open("OneLoopInC.pyx","w+")
file2.write(newinternal)
file2.close()

print("\n\tThe strings were successfully written in the Cython file.\n")
