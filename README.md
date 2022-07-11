#### Table of Contents

* [DAHSI](https://github.com/hribera/DAHSI/blob/master/README.md#dahsi)
* [Installation](https://github.com/hribera/DAHSI/blob/master/README.md#installation)
  * [Base utilities](https://github.com/hribera/DAHSI/blob/master/README.md#base-utilities)
  * [Ipopt](https://github.com/hribera/DAHSI/blob/master/README.md#ipopt)
  * [cyipopt](https://github.com/hribera/DAHSI/blob/master/README.md#cyipopt)
* [Explore DAHSI through a Jupyter Notebook example](https://github.com/hribera/DAHSI/blob/master/README.md#explore-dahsi-through-a-jupyter-notebook-example)
<!--   * [Docker](https://github.com/hribera/DAHSI/blob/master/README.md#docker)
  * [From Source](https://github.com/hribera/DAHSI/blob/master/README.md#from-source) -->
  
-----

# DAHSI

DAHSI (Data Assimilation for Hidden Sparse Inference) is a method to perform model selection in dynamical systems with hidden variables. This method combines the data assimilation technique variational annealing, which has been used to estimate parameters when the structure of the system is known, with sparse model selection via hard thresholding. 

-----

# Installation

⚠️ ⏳ To be able to complete the installation, you will need to get the HSL routines from http://hsl.rl.ac.uk/ipopt. You should download the Coin-HSL Full. Once you have submitted registration form you will receive an email containing a download link (it takes about one working day).

Once you are ready to start, let's download the latest version of DAHSI
```
git clone https://github.com/hribera/DAHSI.git
```

We now will install all necessary dependencies for DAHSI to be able to run. The following installations steps were executed on Ubuntu 20.04 and Python3.9.7. For other versions or systems, you might need to modify some of the steps. 

<!-- ## Docker

You can also test out DAHSI without installing it locally using [Docker](https://www.docker.com/get-started/) by running the following command in the root directory of this repo:
```
docker build --pull --rm -f "Dockerfile" -t dahsi "."
```

This will build an image called `dahsi` and can take up to 15 minutes. Once the image has been created you can run it using the command
```
docker run -it --rm -v "$PWD:/results" dahsi
```

This will launch a terminal in which we are ready to [run an example using DAHSI](https://github.com/hribera/DAHSI/blob/master/README.md#example-lorenz-synthetic-data).

## From source -->

## Base utilities

We first will need to install some base utilities to be able to install DAHSI in our computer. To install these, run the following commands:
```
sudo apt-get update
sudo apt-get install git 
sudo apt-get install wget
sudo apt-get install gfortran

sudo apt-get install -y python3 

sudo apt install python3-pip

sudo apt install build-essential
sudo apt-get install manpages-dev

sudo apt-get install pkg-config
```

### Python libraries

To make sure that you are running the same version of the libraries used, we provide a file with all the requirements (`requirements.txt`) in the DAHSI repository folder). You can install them in a virtual environment so it does not affect your current Python set up.
```
pip3 install -r /requirements.txt
```

## Ipopt

The optimiser used in DAHSI, Ipopt, needs some dependencies to run. Let's create a folder named `MainIpopt` were we will install the dependencies that the optimiser needs. The folder `MainIpopt` can be created anywhere on your computer. Now, go to the directory we just created `MainIpopt`.

### Fast implementation of BLAS and LAPACK.
```
sudo apt-get install libblas-dev liblapack-dev
```

### AMPL Solver Library (ASL).

Make sure you are in the folder `MainIpopt`. To install ASL, we run the commands
```
git clone https://github.com/coin-or-tools/ThirdParty-ASL.git
cd ThirdParty-ASL
./get.ASL
./configure
make clean
make
make install
```

### Harwell Subroutines Library (HSL). MA27, MA57, HSL_MA77, HSL_MA86, and HSL_MA97. 

Go to the folder `MainIpopt` and run

```
git clone https://github.com/coin-or-tools/ThirdParty-HSL.git
cd ThirdParty-HSL
```
In this folder (`ThirdParty-HSL`), unpack the HSL routines and rename it so the directory is `coinhsl` instead of `coinhsl-x.y.z`. Then, we can install HSL by running the commands

```
./configure
make clean
make
make install
```

### MUltifrontal Massively Parallel sparse direct Solver (MUMPS). 

Go to the folder `MainIpopt`. To install MUMPS, we run the commands
```
git clone https://github.com/coin-or-tools/ThirdParty-Mumps.git
cd ThirdParty-Mumps
./get.Mumps
./configure
make clean
make
make install
```
⚠️ If during the installation there are some warning message, do not worry, that's normal.


### Ipopt optimiser

Go to the folder `MainIpopt`. To get, compile and install the latest version of IPOPT we run the following commands:

```
git clone https://github.com/coin-or/Ipopt.git
cd Ipopt
mkdir build
cd build/
../configure
make clean
make
make test
make install
```

Provided that no errors were produced in the previous steps, you now have successfully installed Ipopt! 

## cyipopt

First, we need to install the cython package
```pip install cython```

Go to the folder `MainIpopt`. Now let's download the cyipopt package,
```
git clone https://github.com/mechmotum/cyipopt.git
cd cyipopt/
```

Check whether the Ipopt exectuable is in your path and discoverable by pkg-config

```
pkg-config --libs --cflags ipopt
```

If the command above returns a valid result, the Ipopt exectuable is in your path. Otherwise, you can set the LD_LIBRARY_PATH

```
export PKG_CONFIG_PATH=/your/path/to/the/folder/where/ipopt.pc/is/
```

Now you can to build and install cyipopt,
```
python setup.py install
```

You are now ready to run DAHSI on your computer.

-----

## Explore DAHSI through a Jupyter Notebook example

Go to the `Example_Notebook` folder and open the notebook named `Lorenz_Walkthrough.ipynb`. 



