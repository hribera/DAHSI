#!/bin/bash
#SBATCH --account=b1020     ## <-- EDIT THIS TO BE YOUR ALLOCATION
#SBATCH --partition=b1020   ## <-- EDIT THIS TO BE YOUR QUEUE NAME
#SBATCH --constraint="quest9"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=15:00:00
#SBATCH --mem-per-cpu=10GB
#SBATCH --job-name=sample_job
#SBATCH --array=0-499
#SBATCH --error=arrayJob_%A_%a.err
#SBATCH --output=arrayJob_%A_%a.out 

module load gcc/6.4.0
module load python/anaconda

python main_loop.py ${SLURM_ARRAY_TASK_ID}
