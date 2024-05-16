from snakemake.shell import shell

training_genes = snakemake.input.training_genes
genome = snakemake.input.genome

annotation = snakemake.output.annotation
trained_genes = snakemake.output.trained_genes

shell(f"trainGlimmerHMM {training_genes} -n 150 -v 50 -d {trained_genes}")
#shell(f"python glimmerhmm.py")
shell(f"glimmerhmm {genome} {training_genes} -o {annotation} -g")
