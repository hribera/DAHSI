###############################################################################
### NOTE: No need to change if we keep our problems unconstrained. ############
###############################################################################

from header import *

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

# We also define the apply_new function. 
def apply_new(x):
    return True
