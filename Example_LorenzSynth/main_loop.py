from header import *

import time

import pickle

import os

###############################################################################
### Cost function, its Jacobian and Hessian definitions for PyIpopt. ##########
###############################################################################

from OneLoopInC import eval_f_tricky

from OneLoopInC import eval_grad_f_tricky

from OneLoopInC import eval_h_tricky

# We load the variables needed from ObjNeed.obj created in Define_JacHess.py
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


def eval_f(x):
    assert len(x) == num_total

    return eval_f_tricky(x, Rf)


def eval_grad_f(x):
    assert len(x) == num_total

    return eval_grad_f_tricky(x, Rf)


def eval_h(x, lagrange, obj_factor, flag):
    if flag:
        return (np.array(col_final), np.array(row_final))
    else:
        return eval_h_tricky(x, lagrange, obj_factor, flag, Rf)


class DAHSI():
    def objective(self, x):
        """Returns the scalar value of the objective given x."""
        return eval_f_tricky(x, Rf)

    def gradient(self, x):
        """Returns the gradient of the objective with respect to x."""
        return np.transpose(eval_grad_f_tricky(x, Rf))

    def constraints(self, x):
        """Returns the constraints."""
        return np.array([], float)

    def jacobian(self, x):
        """Returns the Jacobian of the constraints with respect to x."""
        return np.array([])

    def hessianstructure(self):
        """Returns the row and column indices for non-zero vales of the
        Hessian."""

        return (np.array(col_final), np.array(row_final))

    def hessian(self, x, lagrange, obj_factor):
        """Returns the non-zero values of the Hessian."""
        H = eval_h_tricky(x, lagrange, obj_factor, 0, Rf)

        row, col = self.hessianstructure()

        return H


###############################################################################

# Choose seed for random number generation.
IC = int(sys.argv[1])
np.random.seed(IC)

# Bounds for both state variables and parameters. 
x_L = np.ones((num_total))
x_U = np.ones((num_total))

for i in range(num_vars):
    x_L[i:-num_params:num_vars] = float(Input1[1 + 2 * num_vars + num_params + i].split(",")[0])
    x_U[i:-num_params:num_vars] = float(Input1[1 + 2 * num_vars + num_params + i].split(",")[1])
for i in range(num_params):
    x_L[-num_params + i] = float(Input1[1 + 3 * num_vars + num_params + i].split(",")[0])
    x_U[-num_params + i] = float(Input1[1 + 3 * num_vars + num_params + i].split(",")[1])

###############################################################################

# The results.dat file has 3 + num_params columns: \lambda value; \beta value; cost function value; state variables
# and parameter estimates. Open file where results will be stored.

file_name = "D%s_M%s_IC%s_LorenzSynth_V5_s0p01_04.dat" % (num_vars, num_meas, IC)
file_results = os.path.join("outputfiles", file_name)
f = open(file_results, "w+")

lambd = lambd_0

x_jp = np.zeros((num_total))

# Use appropriate initial conditions: for state variables, random; for parameters, set them all to 0.
x0 = (x_U - x_L) * np.random.rand(num_total) + x_L
for i in range(num_meas):
    for k in range(0, num_vars * num_tpoints, num_vars):
        x0[k + i] = data[int(k / num_vars), i]
for i in range(num_params):
    x0[i - num_params] = 0

for i in range(num_total):
    x_jp[i] = x0[i]

# lb = x_L
# ub = x_U

cl = np.array([])
cu = np.array([])

nlp = cyipopt.Problem(
   n=num_total,
   m=0,
   problem_obj=DAHSI(),
   lb=x_L,
   ub=x_U,
   cl=cl,
   cu=cu,
)

# Change some options of the solver.
nlp.add_option('linear_solver', 'ma97')
# nlp.add_option('max_iter',10000)
nlp.add_option('tol', 1.e-12)
nlp.add_option('mu_strategy', 'adaptive')
nlp.add_option('adaptive_mu_globalization', 'never-monotone-mode')
nlp.add_option('bound_relax_factor', float(0))

# Here starts the main loop
while lambd < lambd_max:
    f = open(file_results, "a+")

    Rf0 = 1e-2

    for i in range(num_total):
        x_jp[i] = x0[i]

    for beta in range(beta_max + 1):
        f = open(file_results, "a+")
        # Make note in results file which \lambda and \beta we are at.
        f.write("%f %f " % (lambd, beta))

        # Controlling how much the model is enforced.
        Rf = Rf0 * (alpha ** beta)

        # Solve it via IPOPT (solution is x_jn).
        x_jn, info = nlp.solve(x_jp)
        obj = info['obj_val']

        # We hard threshold the parameter part of the solution (the last num_params elements).
        for i in range(num_params):
            if abs(x_jn[i - num_params]) < lambd:
                x_jn[i - num_params] = 0

        # We set this solution as the initial condition for the next iteration of IPOPT.
        x_jp = x_jn

        # Write cost function value in file.
        f.write("%f " % obj)

        # Write solution in file (at the moment we are only saving the paramter estimate in the file).
        for k in range(num_params):
            f.write("%f " % x_jp[k - num_params])
        f.write("\n")

        f.close()

    # Increase \lambda value.
    lambd = lambd + 0.05
f.close()
