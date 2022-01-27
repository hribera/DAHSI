import os

os.system('python Build_ObjJacHess.py')

os.system('python WriteStrings.py')

os.system('python setup.py build_ext --inplace')