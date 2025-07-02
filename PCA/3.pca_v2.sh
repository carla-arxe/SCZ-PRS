#!/bin/bash

#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --mem=300G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=carla.arxe@autonoma.cat
#SBATCH -J plinkpca

module load plink/2.00
plink2 \
    --bfile UKBB_67292_filtered_EUR \
    --extract UKBB.pruned_v2.prune.in \
    --memory 500000 \
    --pca approx \
    --out UKBB_PCA_v2