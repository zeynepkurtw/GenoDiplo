from snakemake.shell import shell

genome = snakemake.input.genome
db_name = snakemake.params.db_name

shell(f"BuildDatabase -engine ncbi -name {db_name} {genome}")
