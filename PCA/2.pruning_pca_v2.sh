#!/bin/bash

#SBATCH --partition=normal,long
#SBATCH --nodes=1
#SBATCH --mem=180G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=carla.arxe@autonoma.cat
#SBATCH --chdir=/users/genomics/arxe/SCZ/PCA #.out file
#SBATCH -J Pruning_ALL

module load plink/2.00
plink2 \
        --bfile /users/genomics/arxe/SCZ/PCA/UKBB_67292_filtered_EUR \
        --indep-pairwise 50 5 0.2 \
        --out UKBB.pruned_v2   