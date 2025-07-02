#!/bin/bash

#SBATCH --partition=short
##SBATCH --nodes=1
#SBATCH --mem=10G
##SBATCH --mail-type=ALL
##SBATCH --mail-user=carla.arxe@autonoma.cat
#SBATCH --chdir=/users/genomics/arxe/SCZ/PCA #.out file
#SBATCH -J comm_filter

cut -d ' ' -f 1 /projects_ng/UKBIOBANK/shared_data/00-UKBB_67292_genetic_data/00-Genotypic_data/00-Genotypic_calls/UKBB_calls_67292.fam > fam1_col1.txt
awk '{print $1}' /users/genomics/arxe/SCZ/PCA/UKBB_67292_filtered.fam > fam2_col1.txt

awk '{print $2}' /projects_ng/UKBIOBANK/shared_data/00-UKBB_67292_genetic_data/00-Genotypic_data/00-Genotypic_calls/UKBB_calls_67292.bim > bim1_col2.txt
awk '{print $2}' /users/genomics/arxe/SCZ/PCA/UKBB_67292_filtered.bim > bim2_col2.txt

awk '{print $1}' /projects_ng/UKBIOBANK/shared_data/00-UKBB_67292_genetic_data/01-PCA/01-PCA_UKBB_1000G/eigenvectors.txt > vec1_col1.txt
awk '{print $1}' /users/genomics/arxe/SCZ/PCA/UKBB_PCA.eigenvec > vec2_col1.txt


diff fam1_col1.txt fam2_col1.txt
diff bim1_col2.txt bim2_col2.txt

diff vec1_col1.txt vec2_col1.txt
