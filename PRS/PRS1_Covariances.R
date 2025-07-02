print("R script started")
# SCRIPT PRUPOUSE:
# Create the covariances file for PRS.


# IMP: to free memory usage (when working with data requiring big amounts of memory)
rm(list=ls(all.names=TRUE))
invisible(gc())


#Libraries
suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(stringi))


#Upload raw files:
  files <- list.files(path=getwd(), pattern="1M_")
  
  #1: SEX
  filename_uploaded <- files[which(apply(as.array(sapply("SEX", grepl, files)), 1, all))]
  df_sex <- read.table(filename_uploaded, header=TRUE, sep = " ")
  
  
  #2: PCA
  filename_uploaded <- files[which(apply(as.array(sapply("PCA", grepl, files)), 1, all))]
  df_pca <- read.table(filename_uploaded, header=TRUE, sep = "")
  
  
#Merge files:
  df_merged <- left_join(df_sex, df_pca, by=c("FID", "IID"))
 
  
#Save data in a file:
write.table(df_merged, "1M_FID.IID.COVARIANCES.txt", quote=FALSE, col.names=TRUE, row.names=FALSE)

print("R script finished")