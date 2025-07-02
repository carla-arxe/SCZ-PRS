#!/bin/bash

#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=carla.arxe@upf.edu
#SBATCH -J plink

awk 'NR > 1 && $2 == 1 {print $1, $1}' ukb668761_22006.txt > euro_keep.txt

module load plink/2.00

plink2 \
    --bfile /projects_ng/UKBIOBANK/shared_data/00-UKBB_67292_genetic_data/00-Genotypic_data/00-Genotypic_calls/UKBB_calls_67292 \
    --remove /users/genomics/arxe/SCZ/w67292_20241217.txt \
    --keep euro_keep.txt \
    --make-bed \
    --out UKBB_67292_filtered_EUR
