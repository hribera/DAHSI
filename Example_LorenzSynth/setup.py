from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules=[ Extension("OneLoopInC",
              ["OneLoopInC.pyx"],
              libraries=["m"],
              extra_compile_args = ["-ffast-math"])]

setup(
  name = "OneLoopInC",
  cmdclass = {"build_ext": build_ext},
  ext_modules = ext_modules)      

#from distutils.core import setup
#from distutils.extension import Extension
#from Cython.Distutils import build_ext
#
#ext_modules=[ Extension("ProvaClass",
#              ["ProvaClass.pyx"],
#              libraries=["m"],
#              extra_compile_args = ["-ffast-math"])]
#
#setup(
#  name = "ProvaClass",
#  cmdclass = {"build_ext": build_ext},
#  ext_modules = ext_modules)      