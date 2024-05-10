from snakemake.shell import shell

threads = snakemake.params.threads
db_name = snakemake.params.db_name
engine= snakemake.params.engine

shell(f"RepeatModeler -database {db_name} -engine {engine} -pa {threads}")

