###############################################################################
### NOTE: No need to change if we keep our problems unconstrained. ############
###############################################################################

from header import *

Input1 = np.genfromtxt(file1, comments = '#', dtype = 'str')

# We make sure that parameters that will be used as limits in for loops are integers
# and that the time step is a float.
num_vars = int(Input1[0].split(",")[0])
num_params = int(Input1[0].split(",")[1])
num_meas = int(Input1[0].split(",")[2])
dt = float(Input1[0].split(",")[3])
num_tpoints = int(Input1[0].split(",")[4])

# This is the total number of variables that IPOPT will consider.
num_total = num_vars*num_tpoints + num_params

# Here we set up the unconstrained form of the problem.
# Since we have no strong constraints, the constraint function, its jacobian, 
# and its hessian will be an empty array.
nnzj = 0
ncon = 0

g_L = np.array([])
g_U = np.array([])

def eval_g(x):
    assert len(x) == num_total
    return array([ ], float_)

def eval_jac_g(x, flag):
    if flag:
        return (np.array([]),
                np.array([]))
    else:
        assert len(x) == num_total
        return np.array([])

# We also define the apply_new function. I think this is necessary to properly 
# reevaluate the hessian calculation at each step though I am unsure exactly why.
def apply_new(x):
    return True
