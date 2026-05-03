if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# Install Bioconductor and data manipulation packages
# AnnotationDbi: Interface to query biological databases
BiocManager::install(c("org.Hs.eg.db", "GO.db", "AnnotationDbi"), update = FALSE, ask = FALSE)
if (!require("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!require("tidyr", quietly = TRUE)) install.packages("tidyr")

library(org.Hs.eg.db) # Human genome annotation database
library(GO.db) # Gene Ontology database
library(dplyr)
library(tidyr)


# 1. Load Data and Extract Gene Symbols
meta_df <- read.csv("protein_metadata_clean.csv", stringsAsFactors = FALSE)

# Extract the gene symbol before '|' (e.g., 'A1BG' from 'A1BG|NP_570602.2')
meta_df <- meta_df %>%
  separate(Protein_ID, into = c("Gene_Symbol", "RefSeq_ID"), sep = "\\|", remove = FALSE)

gene_symbols <- unique(meta_df$Gene_Symbol)


# 2. Map Gene Symbols to Full Protein Names (GENENAME)
protein_names <- AnnotationDbi::select(org.Hs.eg.db,
                                       keys = gene_symbols,
                                       columns = c("GENENAME"),
                                       keytype = "SYMBOL")

protein_names <- as.data.frame(lapply(protein_names, as.character), stringsAsFactors = FALSE)

# Keep only one unique full name per gene to prevent duplicates
protein_names_clean <- protein_names %>%
  distinct(SYMBOL, .keep_all = TRUE)


# 3. Map Gene Ontology (GO) Terms
# 3-1 Extract GO IDs and Ontology categories
go_info <- AnnotationDbi::select(org.Hs.eg.db,
                                 keys = gene_symbols,
                                 columns = c("GO", "ONTOLOGY"), # 여기서 ONTOLOGY 추가
                                 keytype = "SYMBOL")

go_info <- as.data.frame(lapply(go_info, as.character), stringsAsFactors = FALSE)
go_info <- go_info[!is.na(go_info$GO), ] # Remove NAs

# 3-2 Filter for Biological Process (BP) only
go_info_bp <- go_info %>% 
  filter(ONTOLOGY == "BP")

# 3-3 Fetch text descriptions (TERMs) for the filtered GO IDs
go_terms <- AnnotationDbi::select(GO.db,
                                  keys = unique(go_info_bp$GO),
                                  columns = c("TERM"),
                                  keytype = "GOID")

go_terms <- as.data.frame(lapply(go_terms, as.character), stringsAsFactors = FALSE)

# 3-4 Merge data and collapse multiple GO terms into a single string per gene
go_merged <- go_info_bp %>%
  inner_join(go_terms, by = c("GO" = "GOID")) %>%
  group_by(SYMBOL) %>%
  summarise(GO_Terms_Text = paste(unique(TERM), collapse = "; ")) %>% 
  ungroup()

# 3-5 Merge with full protein names
final_description <- go_merged %>%
  left_join(protein_names_clean, by = "SYMBOL") %>%
  # Rename and reorder columns for database import
  dplyr::select(
    Gene_Symbol = SYMBOL, 
    Full_Name = GENENAME, 
    Description = GO_Terms_Text
  )

# 4. Export the final dataset
write.csv(final_description, file = "protein_description.csv", row.names = FALSE)