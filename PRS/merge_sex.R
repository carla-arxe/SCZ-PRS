# Cargar paquetes necesarios
library(dplyr)

# Leer el archivo de fenotipos
pheno_data <- read.table("Target_data_F20_pheno.txt", header = TRUE)

# Leer el archivo de sexos, eliminando espacios en blanco al inicio
temp_data <- read.table("ukb_31_Sex.txt", header = FALSE, fill = TRUE, stringsAsFactors = FALSE)

# Renombrar las columnas correctamente
colnames(temp_data) <- c("IID", "Sex")

# Eliminar la primera fila (encabezado incorrecto)
sex_data <- temp_data[-1, ]

# Convertir los valores de IID y Sex a numéricos
sex_data$IID <- as.numeric(sex_data$IID)
sex_data$Sex <- as.numeric(sex_data$Sex)

# Unir ambos archivos por la columna IID
merged_data <- left_join(pheno_data, sex_data, by = "IID")

# Reemplazar valores NA en Sex con -9 (asumiendo que los individuos no encontrados deben marcarse como -9)
merged_data$Sex[is.na(merged_data$Sex)] <- -9

# Guardar el archivo resultante
write.table(merged_data, "merged_pheno_sex.txt", row.names = FALSE, quote = FALSE, sep = "\t")