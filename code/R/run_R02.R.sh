#!/bin/bash
#$ -pe smp 10
#$ -l h_vmem=10G
#$ -l h_rt=1:0:0
#$ -cwd
#$ -j y
#$ -N runR
#$ -o /data/SBCS-EizaguirreLab/Alice/StickParaBroOff/GIT_StickParaOffsBroject/code/R/run_R02.R.stdout
#$ -e /data/SBCS-EizaguirreLab/Alice/StickParaBroOff/GIT_StickParaOffsBroject/code/R/run_R02.R.stderr

module load R/4.0.2

Rscript /data/SBCS-EizaguirreLab/Alice/StickParaBroOff/GIT_StickParaOffsBroject/code/R/R02.analysesGlobalMethyl.R
