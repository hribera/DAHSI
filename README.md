README.md is currently being updated. For the time being, refer to the [Installation and Running Guide](DAHSI_Installation_Running_Guide.pdf)

-----

#### Table of Contents

* [DAHSI](https://github.com/hribera/DAHSI/edit/master/README.md#dahsi)
* [Installation](https://github.com/hribera/DAHSI/edit/master/README.md#installation)
  * [Docker](https://github.com/hribera/DAHSI/edit/master/README.md#docker)
  * [From Source](https://github.com/hribera/DAHSI/edit/master/README.md#from-source)
    * [Dependencies](https://github.com/hribera/DAHSI/edit/master/README.md#dependencies)
     * [Python version](https://github.com/hribera/DAHSI/edit/master/README.md#python-version)
    * [Ipopt](https://github.com/hribera/DAHSI/edit/master/README.md#Ipopt)
    * [cyipopt](https://github.com/hribera/DAHSI/edit/master/README.md#cyipopt)
* [Use DAHSI](https://github.com/hribera/DAHSI/edit/master/README.md#use-dahsi)
  * [Example: Lorenz synthetic data](https://github.com/hribera/DAHSI/edit/master/README.md#example-lorenz-synthetic-data)

-----

# DAHSI

DAHSI (Data Assimilation for Hidden Sparse Inference) is a method to perform model selection in dynamical systems with hidden variables. This method combines the data assimilation technique variational annealing, which has been used to estimate parameters when the structure of the system is known, with sparse model selection via hard thresholding. 

-----

# Installation

## Docker

You can also test out DAHSI without installing it locally in [podman](https://podman.io/) by running the following command in the root directory of this repo:
```

```

## From source

### Dependencies

* Python3

* pip
```
sudo apt install python3-pip
```

* C/C++ compiler
```
sudo apt update
sudo apt install build-essential
sudo apt-get install manpages-dev
```

* Fortran libraries
```
sudo apt-get install gfortran
```

* pkg-config
```
sudo apt-get install pkgconfig
```

* Ipopt

The optimiser used in DAHSI, Ipopt, needs some dependencies to run. 

Let's create a folder named `MainIpopt` were we will install the dependencies that the optimiser needs. First, let's go to said directory `cd MainIpopt/`.

* Fast implementation of BLAS and LAPACK.
`sudo apt-get install libblas-dev liblapack-dev`


* AMPL Solver Library (ASL).

To install ASL, we run the commands
```
git clone https://github.com/coin-or-tools/ThirdParty-ASL.git
cd ThirdParty-ASL
./get.ASL
./configure
make
make install
```

* Harwell Subroutines Library (HSL). MA27, MA57, HSL_MA77, HSL_MA86, and HSL_MA97. 

Get the HSL routines from [http://hsl.rl.ac.uk/ipopt](http://hsl.rl.ac.uk/ipopt). You can download the HSL Archive or HSL Full. For our code to run, you need to download the HSL Full. Once you have submitted registration form you will recieve an email containing a download link (it takes about one working day).

```
git clone https://github.com/coin-or-tools/ThirdParty-HSL.git
cd ThirdParty-HSL
```
In this folder, unpack the HSL routines and rename it so the directory is `coinhsl` instead of `coinhsl-x.y.z`. Then, we can install HSL by running the commands

```
./configure
make
make install
```

* MUltifrontal Massively Parallel sparse direct Solver (MUMPS). 

To install MUMPS, we run the commands
```
git clone https://github.com/coin-or-tools/ThirdParty-Mumps.git
cd ThirdParty-Mumps
./get.Mumps
./configure
make
make install
```

#### Ipopt

To get, compile and install the latest version of IPOPT we run the following commands:

```
git clone https://github.com/coin-or/Ipopt.git
cd Ipopt
mkdir build
cd build/
../configure
make
make test
make install
```

Provided that no errors were produced in the previous steps, you now have successfully installed Ipopt! 

#### cyipopt

First, we need to install the cython package
```pip install cython```

Now let's download the cyipopt package,
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
sudo python setup.py install
```

You are now ready to run DAHSI on your computer.

-----

## Use DAHSI

First, download the latest version of DAHSI
```
git clone https://github.com/hribera/DAHSI.git
```

### Example: Lorenz synthetic data

Go to the `Example_LorenzSynth` folder and run
```
python compile.py
python main_loop.py 999
```



