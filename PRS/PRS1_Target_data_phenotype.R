print("R script started")
# SCRIPT PRUPOUSE:
# Create the conversion file for FID and IID of individuals.
# Add phenotypes to target data using the .txt file.


# IMP: to free memory usage (when working with data requiring big amounts of memory)
rm(list=ls(all.names=TRUE))
invisible(gc())


#Libraries
suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(stringi))


#Upload raw files and rearrange data (this may not be necessary in other databases):
  #1: all_data.txt
  files <- list.files(path=getwd(), pattern="\\.txt")
  filename_uploaded <- files[which(apply(as.array(sapply("Target_data_", grepl, files)), 1, all))]
  if (length(filename_uploaded)>1) {
    filename_uploaded <- filename_uploaded[which(apply(as.array(sapply("_ARRANGED_ALLCONTENT", grepl, filename_uploaded)), 1, all))]
  }
  all_data0 <- read.table(filename_uploaded, h=T)
    
  
  #2: Target data upload
  files <- list.files(path=getwd(), pattern="\\.fam")
  filename_uploaded <- files[which(apply(as.array(sapply("POSTIMPtargetdata.fam", grepl, files)), 1, all))]
  filename_uploaded <- filename_uploaded[order(filename_uploaded)][1]
  
    #Rearrange data in a proper dataframe.
    fam0 <- read.table(filename_uploaded, h=F)
    fam1 <- fam0[ , c(1:2)]
    names(fam1) <- c("FID", "IID")

#Create a dataframe relating Individuals ID (IID) to Phenotypes (PHENOTYPE).
  all_data1 <- unique(all_data0[c("IID", "Pheno")])

  #all_data1[which(all_data1$Pheno=="FALSE"),]$Pheno <- "NA"
  #all_data1[which(is.na(all_data1$Pheno)),]$Pheno <- "NA"
  #all_data1[which(all_data1$Pheno=="NA"),]$Pheno <- -9
  #all_data1[which(all_data1$Pheno=="Control"),]$pheno <- 1
  #all_data1[which(all_data1$Pheno=="Paciente"),]$Pheno <- 2
  

#merge both files by IID.
dat <- left_join(fam1, all_data1, by="IID")
if (any(is.na(dat$Pheno))==TRUE) {
  dat[which(is.na(dat$Pheno)),]$Pheno <- -9
}
dat <- dat[order(dat$FID),]
dat[,"Pheno"] <- as.numeric(dat[,"Pheno"])


#Save data in files
write.table(dat, "1I_phenotypes.txt", quote=FALSE, col.names=FALSE, row.names=FALSE)

print("R script finished")