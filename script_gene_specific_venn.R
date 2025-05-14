###################
### PREPARACIÓN ###
###################

# Limpiamos el entorno
rm(list = ls())
gc()

# Librerías
library(dplyr)
library(tidyr)
library(venn)


###########################
### DISEÑO EXPERIMENTAL ###
###########################

# Leer el archivo de TPM
TPM_data <- read.delim("TPM.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE)

# Definir el orden deseado de las condiciones (columnas), comentar si no es necesario
# desired_order <- c("AI4", "CC4", "AI8", "CC8", "AI15", "CC15") 


###########################
########## VENN ###########
###########################

# Crear la carpeta 'results' si no existe
dir.create("results", showWarnings = FALSE)

# Asumimos que la primera columna es el nombre de los genes
gene_column <- colnames(TPM_data)[1]

# Identificar condiciones a partir de los nombres de las columnas
# Suponemos que las columnas siguen un formato como "Condicion_1", "Condicion_2", etc.
condition_names <- unique(sub("_[0-9]+", "", colnames(TPM_data)[-1]))

# Calcular la media por condición y filtrar genes con >= 1 TPM
gene_means <- TPM_data %>%
  pivot_longer(cols = -1, names_to = "Sample", values_to = "TPM") %>%
  mutate(Condition = sub("_[0-9]+", "", Sample)) %>%
  group_by_at(vars(gene_column, "Condition")) %>%
  summarise(Mean_TPM = mean(TPM, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = "Condition", values_from = "Mean_TPM")
  
# Reordenar las columnas según el orden deseado
if (exists("desired_order") && length(desired_order) > 0) {
  gene_means <- gene_means %>% select(all_of(c(gene_column, desired_order)))
}

# Convertir los valores a nombres de genes solo si cumplen la condición de >= 1 TPM
gene_filtered <- gene_means %>%
  mutate(across(-1, ~ ifelse(. >= 1, !!sym(gene_column), "")))

# Eliminar la primera columna (X)
gene_filtered <- gene_filtered[, -1]

# Guardar el archivo filtrado
write.table(gene_filtered, "results/TPM_genes_filtered.tsv", sep = "\t", row.names = FALSE, quote = FALSE, na = "")

# Crear lista de genes por tejido, eliminando vacíos
genes_tissues <- lapply(gene_filtered, function(x) x[x != ""])
genes_tissues <- genes_tissues[lengths(genes_tissues) > 0]  # Filtrar listas vacías

# Graficar y exportar el diagrama de Venn
pdf("results/Venn_Diagram.pdf", width = 5.5, height = 5.5)
venn_res <- venn(genes_tissues, ilabels = "counts", zcolor = "style")
dev.off()

# Extraer datos de intersecciones y guardar cada comparación en un archivo separado
venn_data <- attr(venn_res, "intersections")
lapply(names(venn_data), function(comp) {
  file_name <- paste0("results/Venn_", gsub("[^A-Za-z0-9_]", "_", comp), ".txt")
  writeLines(c(comp, venn_data[[comp]]), file_name) # Añade la cabecera, para el script de enriquecimiento
  #writeLines(venn_data[[comp]], file_name) # Quita la cabecera
})

# Guardar todas las comparaciones en un TSV
write.table(
  data.frame(Comparison = names(venn_data), 
             Genes = sapply(venn_data, paste, collapse = "; ")), 
  "results/Venn_Genes.tsv", sep = "\t", row.names = FALSE, quote = FALSE
)
