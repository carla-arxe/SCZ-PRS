#!/bin/bash

#SBATCH --partition=bigmem
#SBATCH --nodelist=node03
#SBATCH --mem=300G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=carla.arxe@autonoma.cat


###################################################################
######################### START ANALISIS ##########################
###################################################################
########### Script: 04 PRS PIPELINE FOR GENOTYPED DATA ############
########################### Author: PRC ###########################
########################## Version: v3 ##########################
###################################################################


###################################################################
### IMPORTANT INSTRUCTIONS TO RUN THE PIPELINE OF THIS SCRIPT ###

# Run the present script into the folder containing all files from your data.

# RENAME ORIGINAL FILES: original files needs to be renamed adding at the begining of the name:
	# For target data: "POSTIMPtargetdata" (for .bed/.bim/.fam files).
	# For base data: "Basedata_*****.txt"
	# For SNP list: "SNPlist_*****.txt" (for any file of the NT extended and common lists)
	# For individuals rename: "Target_data_*****.txt" (for individuals' FID and IID in step 1.2; phentoypes in step 1.3; and sex in step 1.4)
	
	
#### According to the original database info, in case it is needed to take in consideration Phenotypes and the .fam file DO NOT contain only and specifically in this order the information (FID | IID | PHENO) with PHENO values 1(for Healthy Controls), 2(for Patients), and -9 (for NA), this info is going to be added in the PRS step.


# FOLDER MUST CONTAINING FILES:
	#### 04_PRS_DATA_PIPELINE_PRC_v3.sh
	#### POSTIMPtargetdata.bed
	#### POSTIMPtargetdata.bim
	#### POSTIMPtargetdata.fam
	#### Basedata_*****.txt
	#### Target_data_*****.txt (for individuals' FID and IID in step 1.2; phentoypes in step 1.3; and sex in step 1.4)
	#### SNPlist_*****.txt (for any file of the NT extended and common lists)
	#### *.eigenvec
	#### PRS1_FID_IID.R (for step 1.2)
	#### PRS1_Target_data_phenotype.R (for step 1.3)
	#### PRS1_Covariances.R (for step 1.5)
	#### PRS3_PRS_all.R (for step 3)
	#### PRS3_PRS-PCA.R (for step 3)
	#### PRS3_Models.Rmd (for step 3)
	#### PRS3_Deciles.R (for step 3)


# NOTE: If imputation were with TOPMed, its output were in GRCh38 (hg38) and we want as original GRCh37 (hg19). Thus a would be liftover is needed in step 1.1.

# In this script, THE ONLY variables that need to be modified are the followings: 
	#### Specify plink executable (folder and executable):
	#runliftover="/home/pol/bin/liftOver/liftOver" #path to UCSC liftOver tool
	#liftoverChain="/home/pol/bin/liftOver/hg38ToHg19.over.chain" #chain file to conversion hg38 to hg19
	#runplink="/home/pol/bin/PLINK/plink" #path to run plink
	module load plink/2.00
	runprsice="/users/genomics/arxe/SCZ/PRSice_linux/PRSice.R" #path to run prsice R script
	prsiceOS="/users/genomics/arxe/SCZ/PRS_NT/PRSice_linux" #path to run prsice OS exectuable
	
	##### Do you need to perform the following steps? (Answer: "YES" or "NO"):
		##### Step 1: POSTIMPUTED TARGET DATA LIFTOVER.
		step1liftover="NO" #step1.1
	
	##### Other variables for the Base data:
	#step23list=('ext' 'com')
	#step23sublist=('DA' 'GABA' 'Glu' 'HT' 'NT')

	##### The current variables for PRSice are going to be the following:
	prsiceSNP="ID" #basedata SNP ID columnname
	prsiceCHR="CHROM" #basedata SNP chromosome columnname
	prsiceBP="POS" #basedata SNP base postion columnname
	prsiceA1="A1" #basedata SNP A1 columnname
	prsiceA2="A2" #basedata SNP A1 columnname
	prsiceINFO="IMPINFO:0.9" #basedata INFO columnname:threshold
	prsiceOR="BETA" #basedata OR columnname
	prsicePVAL="PVAL" #basedata PVAL columnname
	prsiceClumpLD=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1) #Clumping LD for R2.
	prsicePTBarLevel=(0.00000005 0.0000005 0.000005 0.00005 0.0005 0.005 0.05 0.1 0.5 1) #PT to calculate PRS and the level of barchart to be plotted 
	

# At this moment, in order to run the script, you need to be in the current folder from a terminal and type the following command: "bash 4_PRS_DATA_PIPELINE_PRC_v3.sh"

# And once it finish, your final DECILES data is going to be under the name "PRS_*****.txt/.pdf/.html", which "PRS_individuals_deciles.txt" is the one needed for the next pipeline step.

# PRINT THE PARAMETRES OF THE CURRENT RUN:
printf "### Script: 04 PRS PIPELINE FOR GENOTYPED DATA
### Author: PRC
### Version: v3

### PARAMETERS OF THE CURRENT RUN:
Step 1.1: liftover = %s

Step 3: BD colname SNP = %s
Step 3: BD colname CHR = %s
Step 3: BD colname BP = %s
Step 3: BD colname A1 = %s
Step 3: BD colname A2 = %s
Step 3: BD colname INFO & threshold = %s
Step 3: BD colname OR = %s
Step 3: BD colname PVAL = %s
Step 3: BD LD clumping R2 = %s %s %s %s %s %s %s %s %s %s
Step 3: BD PVAL thresholding = %s %s %s %s %s %s %s %s %s %s" "$step1liftover" "$prsiceSNP" "$prsiceCHR" "$prsiceBP" "$prsiceA1" "$prsiceA2" "$prsiceINFO" "$prsiceOR" "$prsicePVAL" "${prsiceClumpLD[@]}" "${prsicePTBarLevel[@]}" > 04_PRS_DATA_PIPELINE_PRC_v3.log


echo "### Script running...enjoy!"


###################################################################
### Step 3: POLYGENIC RISK SCORE ###
echo "### Starting Step 3: polygenic risk score ###"

module load R
# For Original GWAS. Run a PRS in bucle for the different Pvals and LDs setted.
mkdir 3_PRSice_originalBasedata

for ClumpLD in ${prsiceClumpLD[@]}
do
	for PT in ${prsicePTBarLevel[@]}
	do
		echo "Starting PRS for ld=$ClumpLD and PT=$PT"
		
		Rscript $runprsice \
		--prsice $prsiceOS \
		--cov 1M_FID.IID.COVARIANCES.txt \
		--pheno 1J_FID.IID.PHENOTYPE.txt \
		--pheno-col PHENOTYPE\
		--target POSTIMPtargetdata_EUR \
		--binary-target T \
		--base 2B_Basedata_PGC_SCZ_european.txt \
		--snp $prsiceSNP \
		--chr $prsiceCHR \
		--bp $prsiceBP \
		--A1 $prsiceA1 \
		--A2 $prsiceA2 \
		--base-info $prsiceINFO \
		--beta \
		--stat $prsiceOR \
		--pvalue $prsicePVAL \
		--clump-r2 $ClumpLD \
		--bar-levels $PT \
		--fastscore \
		--no-full \
		--quantile 10 \
		--out PRS.PGC_SCZ_european
		
		awk {'print $1,$2,$4'} *.best > 3_PRS_individuals_specific.txt
		sed -i "1s/PRS/ClLD${ClumpLD}_PT${PT}/" 3_PRS_individuals_specific.txt
		
		if ! test -f 3_PRS_individuals_all.txt;
			then
				cp 3_PRS_individuals_specific.txt 3_PRS_individuals_all.txt										
			else
				Rscript --no-save PRS3_PRS_all.R
				rm 3_PRS_individuals_specific.txt		
		fi		
		
		for i in $( find . -name 'PRS.PGC_SCZ_european*' -printf '%f\n' ); do mv ${i} 3_ClLD${ClumpLD}_PT${PT}_${i} ; done
		mkdir ./3_PRSice_originalBasedata/3_ClLD${ClumpLD}_PT${PT} ; find 3_Cl* -maxdepth 1 -type f | xargs -I {} mv {} ./3_PRSice_originalBasedata/3_ClLD${ClumpLD}_PT${PT}/
		
		echo "Finished PRS for ld=$ClumpLD and PT=$PT"
	done
done

Rscript --no-save PRS3_PRS-PCA.R

#Local
#R -e "rmarkdown::render('PRS3_Models.Rmd', 'html_document', output_file='3_PRS_Models.html')"
#Rscript --no-save PRS3_Deciles.R

for i in $( find . -maxdepth 1 -name '3_PRS_*' -printf '%f\n' ); do mv "$i" "${i#3_}" ; done
mv PRS_* ./3_PRSice_originalBasedata


		
echo "### End of Step 3: polygenic risk score ###"


###################################################################
### ENDING ###

# Move all files created into another subdirectory:
#rm -r _FilesCreated; mkdir _FilesCreated
#mv 1* 2* ./_FilesCreated/

# Remove unnecesary input Bfiles created cretated by plink (ended with ~)
#rm *~

#echo "### CONGRATULATIONS! You've just succesfully completed the PRS tutorial! You are now able to conduct a proper genetic PRS."


###################################################################
