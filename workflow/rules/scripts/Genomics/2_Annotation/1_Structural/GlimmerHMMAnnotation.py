from snakemake.shell import shell

training_genes = snakemake.input.training_genes
genome = snakemake.input.genome

gff = snakemake.output.gff
trained_genes = snakemake.output.trained_genes

shell(f"trainGlimmerHMM {genome} {training_genes} -n 150 -v 50 -d {trained_genes}")
#shell(f"python glimmerhmm.py")
#shell(f"glimmerhmm {genome} {training_genes} -o {gff} -g")
