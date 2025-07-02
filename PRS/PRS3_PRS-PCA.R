print("R script started")
# SCRIPT PRUPOUSE:
# Create a correlation-based PCA from the individuals' PRS combinations (P-threshold and LD) for all the target individuals # Approach A: adapted from the code in the Supplementary figures of Coombes 2020.


# IMP: to free memory usage (when working with data requiring big amounts of memory)
rm(list=ls(all.names=TRUE))
invisible(gc())


#Libraries
suppressMessages(library(dplyr))
suppressMessages(library(tidyr))


# INPUTS:
# dat = n x (p+1) dataframe of PRSs under different settings with first column as ID
df_all <- read.table("3_PRS_individuals_all.txt", header=TRUE, sep=" ")


#Plot original data:
#Have a look on the data by frequencies of the column PRS:
pdf("3_PRS_data-distribution.pdf")
par(mfrow=c(3,4))
for (i in seq_along(3:NCOL(df_all))) {
  xmin <- round(min(df_all[i+2]), 5)
  xmax <- round(max(df_all[i+2]), 5)
  hist(df_all[,i+2], main=names(df_all)[i+2], xlab="PRS", xaxt='n')
  axis(1, at=c(xmin,xmax), labels=c(xmin,xmax))
}


############################ APPROACH A: Coombes et. al., 2020 ##########################################

# ARRANGE INPUT DATA FOR THE APPROACH.
df_a <- df_all
df_a$FID_IID <- paste(df_a[,1], df_a[,2], sep="_|_")
df_a <- df_a[,c(length(df_a), 3:(length(df_a)-1))]


# FUNCTION
prs.pc <- function(df_a,x){
  xo <- scale(as.matrix(df_a[,-1]))  ## scale cols of matrix of only PRSs (remove ID)
  g <- prcomp(xo)   ## perform principal components
  eigSum.g <<- summary(g)
  pca.r2 <- g$sdev^2/sum(g$sdev^2)    ## calculate variance explained by each PC
  pc1.loadings <- g$rotation[,1]      ## loadings for PC1
  
  ## Flip direction of PCs to keep direction of association (sign of loadings for PC1 is arbitrary so we want to keep same direction)
  if (mean(pc1.loadings>0)==0){     
    pc1.loadings <- pc1.loadings*(-1) 
  }
  pc1.loadings <<- pc1.loadings
  
  ## calculate PRS-PCA (outputs PC1 and PC2 even though PC1 sufficient)
  pc1 <- xo %*% pc1.loadings
  df_a$PC1 <- scale(pc1)  ## rescales PRS-PCA1
  
  ## Get from dataframe only PC1 and separates FID_IID
  df <- df_a %>% separate_wider_delim(FID_IID, "_|_", names=c("FID", "IID"))
  df <- as.data.frame(df[,c("FID", "IID", "PC1")])
  df$FID <- as.character(df$FID)
  df$IID <- as.character(df$IID)
  df$PC1 <- as.numeric(df$PC1)
  
  ## OUTPUTS:
  # a list of 
  #  - data = dataframe with individuals and PC1 (FID, ID , PC1)
  #  - r2 = variance explained by each PC of the PRS matrix
  #  - loadings = the PC-loadings used to create PCA1
  list_prs.pc <<- list(scaled=xo, pca=g, pc1=df, r2=as.vector(pca.r2), loadings=pc1.loadings)
}
prs.pc(df_a,x)



  
############################# PLOT ########################################  
  #Plot all dataframes together to compare original, standardised and scaled.
  l_df.plot <- list()
  l_df.plot[["Original data"]] <- c(as.matrix(df_all[,3:(length(df_all))]))
  l_df.plot[["A: Scaled data"]] <- c(as.matrix(list_prs.pc$scaled))
  l_df.plot[["A: PC1 of scaled data"]] <- c(as.matrix(list_prs.pc$pc1[["PC1"]]))
  
  par(mfrow=c(2,2))
  for (i in seq_along(l_df.plot)) {
    xmin <- round(min(l_df.plot[[i]]), 5)
    xmax <- round(max(l_df.plot[[i]]), 5)
    hist(l_df.plot[[i]], main=names(l_df.plot[i]), xlab="Data range", xaxt='n')
    axis(1, at=c(xmin,xmax), labels=c(xmin,xmax))
  }
  
  
############################# COMPARE APPROACHES ########################################  

  #PC1 Loadings
  par(mfrow=c(2,1))
    xmin <- round(min(pc1.loadings), 2)
    xmax <- round(max(pc1.loadings), 2)
    hist(pc1.loadings, main="A: PC1 loadings \n of PRS thresholds", xlab="PC1 loadings", xaxt='n')
    axis(1, at=c(xmin,xmax), labels=c(xmin,xmax))
    

  #Plot the Proportion of Variance explained by each component (eig sum Proportion above)
    #Approach A:
    plot(eigSum.g$importance["Proportion of Variance",c(1:10)], xlim=c(1, 10), ylim=c(0, 1), type="b", pch=16, main="A: PC's variance explanation \n of PRS thresholds", sub=paste0("The PC1 explains the ",round(eigSum.g$importance["Proportion of Variance",1]*100), "% of variance."), xlab="principal components (PC)", ylab="variance explained (%)", xaxt="n", yaxt="n")
    axis(side=1, at=seq(1, 10, by=1))
    axis(side=2, at=seq(0, 1, by=0.1))
  
  
#Close pdf to store plots generated
invisible(dev.off())

#Save data in files
write.table(list_prs.pc$pc1, "3_PRS_individuals_PC1.txt", quote=FALSE, col.names=TRUE, row.names=FALSE)

print("R script finished")