#!/bin/bash
#SBATCH --job-name=test-sbatch
#SBATCH --output=test-sbatch.out
#SBATCH --error=test-sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --mem-per-cpu=50G
#SBATCH --nodes=1

### DO NOT CHANGE! ###

## setup computing environment ##

cd /project2/xinhe/yanyul
source setup.sh
source activate deepvarpred_test

#################################


### CHANGE BELOW ####

#### setup working directory ####

cd /scratch/midway2/xinhe/repo/deep_variant_annotation/

######### run snakemake #########

snakemake --configfile config.test.yaml -p

#################################
