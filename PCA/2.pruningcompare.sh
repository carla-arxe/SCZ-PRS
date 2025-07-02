#!/bin/bash

#SBATCH --partition=short
##SBATCH --nodes=1
#SBATCH --mem=10G
##SBATCH --mail-type=ALL
##SBATCH --mail-user=carla.arxe@autonoma.cat
#SBATCH --chdir=/users/genomics/arxe/SCZ/PCA #.out file
#SBATCH -J comm_SNP

sort /projects_ng/UKBIOBANK/shared_data/00-UKBB_67292_genetic_data/01-PCA/01-PCA_UKBB_1000G/indepSNP.prune.in -o archivo1.prune.in.sorted
sort /users/genomics/arxe/SCZ/PCA/UKBB.pruned.prune.in -o archivo2.prune.in.sorted

comm -23 archivo1.prune.in.sorted archivo2.prune.in.sorted > ids1.txt
comm -13 archivo1.prune.in.sorted archivo2.prune.in.sorted >ids2.txt



