print("R script started")
# SCRIPT PRUPOUSE:
# Join into a matrix the specifics PRS according P-threshold for all the individuals.

# IMP: to free memory usage (when working with data requiring big amounts of memory)
rm(list=ls(all.names=TRUE))
invisible(gc())

#Libraries
suppressMessages(library(dplyr))

#Upload raw files and rearrange data (this may not be necessary in other databases):
df_all <- read.table("3_PRS_individuals_all.txt", header=TRUE, sep = " ")
df_spe <- read.table("3_PRS_individuals_specific.txt", header=TRUE, sep = " ")
  
#Join tables
df_join <- left_join(df_all, df_spe, by=c("FID","IID"))

#Save data in files
write.table(df_join, "3_PRS_individuals_all.txt", quote=FALSE, col.names=TRUE, row.names=FALSE)

print("R script finished")