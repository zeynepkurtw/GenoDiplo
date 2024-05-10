from snakemake.shell import shell

threads = snakemake.threads
db_name = snakemake.params.db_name

shell(f"RepeatModeler -database {db_name} -engine ncbi -pa {threads}")

