import numpy as np

# Read the input text files.
# There's three of them...
#    1) File1.txt includes information about the number of state variables, 
#       parameters, measured state variables, time step and total number of time points;
#       the variable and parameter names; the equations of the system at hand; 
#       the bounds for both state variables and parameters search.
#    2) File2.txt includes information about the measured state variables, 
#       the files in which the data can be found and the form the measurement part of the action takes.
#    3) File3.txt inlcudes information about parameters needed to do the variational annealing
#       as well as the search in lambda.

Input1 = np.genfromtxt('File1.txt', comments = '#', dtype = 'str')
Input2 = np.genfromtxt('File2.txt', comments = '#', dtype = 'str')
Input3 = np.genfromtxt('File3.txt', comments = '#', dtype = 'str')

# We make sure that parameters that will be used as limits in for loops are integers
# and that the time step is a float.
num_vars = int(Input1[0].split(",")[0])
num_params = int(Input1[0].split(",")[1])
num_meas = int(Input1[0].split(",")[2])
dt = float(Input1[0].split(",")[3])
num_tpoints = int(Input1[0].split(",")[4])

# This is the total number of variables that IPOPT will consider.
num_total = num_vars*num_tpoints + num_params

# Here we save all the data from the different measured state variables.
data = np.zeros((num_tpoints,num_meas))

for i in range(num_meas):
#    filename = "%s" % Input2[num_meas+1+i]
    filename = "%s" % Input2[num_meas+i]
    data[:,i] = np.loadtxt(filename)
    
# 
alpha = float(Input3[0])

# Number of annealing steps.
beta_max = int(Input3[1])

# First lambda in our sweep.
lambd_0 = float(Input3[2])

# Maximum lambda in our sweep.
lambd_max = float(Input3[2+1])