#!/bin/bash
#SBATCH --job-name=test-gpu
#SBATCH --output=test-gpu.out
#SBATCH --error=test-gpu.err
#SBATCH --time=24:00:00
#SBATCH --partition=gpu2
#SBATCH --mem-per-cpu=50G
#SBATCH --nodes=1
#SBATCH --gres=gpu:1

### DO NOT CHANGE! ###

## setup computing environment ##

cd /project2/xinhe/yanyul
source setup.sh
source activate deepvarpred_test
module load cuda/7.5

#################################


### CHANGE BELOW ####

#### setup working directory ####

cd /scratch/midway2/xinhe/repo/deep_variant_annotation/

######### run snakemake #########

snakemake --configfile config.test.yaml -p

#################################
