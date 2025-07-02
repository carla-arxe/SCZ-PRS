print("R script started")
# SCRIPT PRUPOUSE:
# Using the residuals per each individual, identifying the deciles they belong.


# IMP: to free memory usage (when working with data requiring big amounts of memory)
rm(list=ls(all.names=TRUE))
invisible(gc())


#Libraries
suppressMessages(library(cowplot))
suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))
suppressMessages(library(plyr))
suppressMessages(library(RColorBrewer))


# INPUTS:
  # Phenotype (FID, IID, PHENOTYPE)
  df_pheno <- read.table("1J_FID.IID.PHENOTYPE.txt", header=TRUE, sep=" ")
  df_pheno[df_pheno$PHENOTYPE==0,"PHENOTYPE"] <- "Control"
  df_pheno[df_pheno$PHENOTYPE==1,"PHENOTYPE"] <- "Case"
                   
  # Phenotype (FID, IID, SEX)
  df_sex <- read.table("1M_FID.IID.SEX.txt", header=TRUE, sep=" ")
  df_sex[df_sex$SEX==1,"SEX"] <- "Male"
  df_sex[df_sex$SEX==0,"SEX"] <- "Female"
  
  # Phenotype (FID, IID, PRS.PC1.res)
  df_res <- read.table("3_PRS_PC1_res.txt", header=TRUE, sep=" ")
  

# MERGE ALL DATABASES
l_all <- list("pheno"=df_pheno, "sex"=df_sex, "prs.pc1.res"=df_res) 
df_all <- Reduce(function(x, y) merge(x, y, all=FALSE), l_all)
df_all$SEX <- as.factor(df_all$SEX)
df_all$PHENOTYPE <- as.factor(df_all$PHENOTYPE)

  
# PLOT.
pdf("3_PRS_Quantiles.pdf")
  # Explore distributions:
    # Counts
    mean_res <- mean(df_all$PRS.PC1.residual)
    P1 <- ggplot(df_all, aes(x=PRS.PC1.residual)) +
      geom_histogram(binwidth=.5, colour="black", fill="white") +
      geom_vline(aes(xintercept=mean_res), color="red", linetype="dashed", linewidth=0.7) +
      labs(title="PRS distribution", x="PRS-PC1 residual", y="Counts") +
      theme(plot.title=element_text(hjust=0.5))

    # Density
    P2 <- ggplot(df_all, aes(x=PRS.PC1.residual)) +
      geom_histogram(aes(y=after_stat(density)), binwidth=.5, colour="black", fill="white") +
      geom_density(alpha=.2, fill="#FF6666") +
      labs(title="PRS distribution", x="PRS-PC1 residual", y="Density") +
      theme(plot.title=element_text(hjust=0.5))
    
    # Density - by Sex
    mean_sex <- ddply(df_all, "SEX", summarise, grp.mean=mean(PRS.PC1.residual))
    P3 <- ggplot(df_all, aes(x=PRS.PC1.residual, fill=SEX, color=SEX)) +
      geom_density(alpha=.2) +
      geom_vline(data=mean_sex, aes(xintercept=grp.mean, color=SEX), linetype="dashed", show.legend=FALSE) +
      labs(title="PRS distribution by SEX", x="PRS-PC1 residual", y="Density") +
      theme(plot.title=element_text(hjust=0.5), legend.position="top")
    
    # Density - by Phenotype
    mean_pheno <- ddply(df_all, "PHENOTYPE", summarise, grp.mean=mean(PRS.PC1.residual))
    P4 <- ggplot(df_all, aes(x=PRS.PC1.residual, fill=PHENOTYPE, color=PHENOTYPE)) +
      geom_density(alpha=.2) +
      geom_vline(data=mean_pheno, aes(xintercept=grp.mean, color=PHENOTYPE), linetype="dashed", show.legend=FALSE) +
      labs(title="PRS distribution by PHENOTYPE", x="PRS-PC1 residual", y="Density") +
      theme(plot.title=element_text(hjust=0.5), legend.position="top")
    
    plot_grid(P1, P2, P3, P4, ncol=2, nrow=2)
  
    
  # Explore Deciles:    
    #Plot Quantile-Quantile
    P5 <- ggplot(df_all, aes(sample=PRS.PC1.residual)) +
      stat_qq() +
      stat_qq_line(color="cyan4") +
      labs(title="Normal Q-Q Plot", x="Theoretical Quantiles", y="Sample Quantiles") +
      theme(plot.title=element_text(hjust=0.5))
        
    plot_grid(P5, ncol=1, nrow=1)
      
      
    # Convert variables to factors and get deciles
    df_all$DECILE <- as.numeric(ntile(df_all$PRS.PC1.residual, 10))
    col_decile <- brewer.pal(10, "Set3")
    names(col_decile) <- 1:10
    df_all$color <- NA
    b <- df_all[FALSE,]
    max_num_decile <- vector()
    for (i in seq_along(col_decile)) {
      a <- df_all[df_all$DECILE==names(col_decile)[i], ]
      a$color <- col_decile[i]
      b <- rbind(a,b)
      c <- NROW(a)
      max_num_decile <- max(c(max_num_decile,c))
    }
    df_all <- b[match(df_all$FID, b$FID),]
    df_all$color <- as.factor(df_all$color)
        
      #PLOT HISTOGRAM OF DECILES
      P6 <- ggplot(df_all, aes(x=DECILE, fill=color)) +
        geom_histogram(binwidth=.5) +
        geom_text(stat='count', aes(label=after_stat(count)), vjust=-1) +
        ylim(0, round(max_num_decile/100, 1)*100+50) +
        scale_x_continuous(breaks=seq(1, 10, 1)) +
        labs(title="Quantiles counts", x="Deciles", y="Counts") +
        theme(plot.title=element_text(hjust=0.5), legend.position="none")
          
          
        df_all_decile <- df_all %>%
          dplyr::group_by(DECILE, PHENOTYPE) %>%
          dplyr::summarise(n = n()) %>%
          dplyr::mutate(prop = n / sum(n)) %>%
          dplyr::ungroup() %>%
          dplyr::mutate(DECILE=as.factor(DECILE))
          
        P7 <- ggplot(df_all_decile, aes(x=DECILE, y=prop, fill=PHENOTYPE)) +
          geom_bar(stat="identity") +
          geom_text(aes(label=paste0(round(prop,2)*100, "%\n(", n, ")")), position=position_stack(vjust=0.5)) +
          labs(title="Control vs Case in Deciles", x="Deciles", y="Percentage (%)") +
          theme(plot.title=element_text(hjust=0.5), legend.position="top")
        
        plot_grid(P6, P7, ncol=1, nrow=2)
        
          
    #Create a decile dataframe for its representation:
      # Put deciles in 0-1 scale
      df_all$decile_model <- factor(.bincode(df_all$PRS.PC1.residual, breaks=quantile(df_all$PRS.PC1.residual, seq(0, 1, 0.1)), include.lowest=TRUE), levels=c(5, 1, 2, 3, 4, 6, 7, 8, 9, 10))
          
      # For models, the phenotype variable must be "0" (in controls) and "1" (in cases).
      df_all$pheno_model <- as.character(df_all$PHENOTYPE)
      df_all[which(df_all$pheno_model=="Control"),"pheno_model"] <- 0
      df_all[which(df_all$pheno_model=="Case"), "pheno_model"] <- 1
      df_all$pheno_model <- as.numeric(df_all$pheno_model)
        
      # Fit regression model 
      model <- glm(pheno_model ~ decile_model, data=df_all, family='binomial')
      summary(model)
          
      # Get summary data
      my_sum_data <- as.data.frame(cbind(exp(confint(model, level=.90)[2:10,]), "Odds ratio"=round(exp(coef(model)[2:10]), 2), "P value"=summary(model)$coefficients[2:10, 'Pr(>|z|)']))
      colnames(my_sum_data) <- c("lower", "upper", "odds_ratio", "p_val")
      my_sum_data <- rbind(my_sum_data, c(1,1,1,1))
      my_sum_data$decile_model <- factor(c(1,2,3,4,6,7,8,9,10,5))
      
      # Plot odds ratio
      P8 <- ggplot(my_sum_data, aes(decile_model, odds_ratio)) +
        geom_errorbar(aes(ymin = lower, ymax = upper), width=.2) +
        geom_hline(yintercept = 1, linetype = "dashed", color = "grey") +
        geom_point(shape=22, size=6, color="black", fill="cyan", stroke=.8) +
        scale_y_continuous(limits=c(0, ceiling(max(my_sum_data$upper))), breaks=seq(0, ceiling(max(my_sum_data$upper)), 1)) +
        labs(title="Binomial logistic regression \nodds ratio per decile", x="PRS Deciles", y="Odds ratio") +
        theme_bw() +
        theme(plot.title=element_text(hjust=0.5))
      
      plot_grid(P8, ncol=1, nrow=1)

  

# CLOSE PDF TO STROE PLOTS GENERATED
invisible(dev.off())

# SAVE DATA IN FILES
write.table(df_all[,1:6], "3_PRS_individuals_deciles.txt", quote=FALSE, col.names=TRUE, row.names=FALSE)
write.table(my_sum_data, "3_PRS_Deciles.OR.txt", quote=FALSE, col.names=TRUE, row.names=FALSE)

print("R script finished")