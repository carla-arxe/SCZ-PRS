print("R script started")
# SCRIPT PRUPOUSE:
# Create the covariances file for PRS.

# ========================
# IMP: to free memory usage (when working with data requiring big amounts of memory)
rm(list=ls(all.names=TRUE))
invisible(gc())


#Libraries
suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(stringi))
suppressMessages(library(purrr))



#Upload raw files:
  files <- list.files(path=getwd(), pattern="1M_")
  
  #1: SEX
  filename_uploaded <- files[which(apply(as.array(sapply("SEX", grepl, files)), 1, all))]
  df_sex <- read.table(filename_uploaded, header=TRUE, sep = " ")
  
  
  #2: PCA
  filename_uploaded <- files[which(apply(as.array(sapply("PCA", grepl, files)), 1, all))]
  df_pca <- read.table(filename_uploaded, header=TRUE, sep="")

# ========================
# 3. CARGAR NUEVOS COVARIABLES
# ========================

df_extra <- read.table("N_PCA_condunders_IDs.tab", header = TRUE, sep = "\t", stringsAsFactors = FALSE)

head(df_extra)

df_extra <- df_extra[, -c(3:12, 14)]


# ========================
# 5. UNIR CON SEX Y PCA
# ========================
# Convertir FID e IID a character en todos los dataframes
df_sex <- df_sex %>%
  mutate(FID = as.character(FID), IID = as.character(IID))

df_pca <- df_pca %>%
  mutate(FID = as.character(FID), IID = as.character(IID))

df_extra <- df_extra %>%
  mutate(FID = as.character(FID), IID = as.character(IID))


df_covariates <- df_sex %>%
  left_join(df_pca, by = c("FID", "IID")) %>%
  left_join(df_extra, by = c("FID", "IID"))

# ========================
# 6. FILTRAR ARCHIVO
# ========================

  # Cargar archivos
fam <- read.table("POSTIMPtargetdata_EUR.fam")

# Renombrar por si acaso
names(fam)[1:2] <- c("FID", "IID")

# Filtrar
cov_filtrado <- df_covariates[paste(df_covariates$FID, df_covariates$IID) %in% paste(fam$FID, fam$IID), ]


# ========================
# 6. GUARDAR ARCHIVO FINAL
# ========================

write.table(cov_filtrado, "1M_FID.IID.COVARIATES.ALL_v2.txt", quote = FALSE, col.names = TRUE, row.names = FALSE, sep = " ")

print("✅ Script terminado. Archivo final guardado como: 1M_FID.IID.COVARIATES.ALL.txt")
