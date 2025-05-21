# gene-specific-venn
This R script generates a Venn diagram based on gene expression specificity across experimental conditions.

## What it does
* Reads a normalized count matrix (e.g., `TPM.tsv`), where columns are samples and rows are genes.
* Calculates the average values per condition.
* Filter and identifies genes that are specifically expressed in one condition (≥ 1 in only one).
* Builds a Venn diagram showing overlaps across all conditions.
* Outputs:
  * A filtered TSV file of gene IDs per condition (e.g., `TPM_genes_filtered.tsv`)
  * A Venn diagram (`Venn_Diagram.pdf`)
  * Gene lists for each intersection (`Venn_*.txt`)
  * A summary file with all comparisons (`Venn_Genes.tsv`)

## Requirements
* `dplyr`
* `tidyr`
* `venn`

## Input
A TSV file. It should have:
* One gene per row
* Samples as columns (e.g., `AI4_1`, `AI4_2`, `CC4_1`, etc.)
* TPM values as content

## Usage
Run in R:
```r
source("gene_specific_venn.R")
```
Make sure the script is in the correct directory relative to the TPM file.

## Output
All results are saved in the `results/` directory.
