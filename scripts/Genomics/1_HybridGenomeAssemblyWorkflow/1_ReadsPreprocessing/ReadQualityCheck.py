from snakemake.shell import shell

input_dir = snakemake.input.input_dir
out = snakemake.output

shell(f"cd {input_dir}")
shell(f"fastqc --threads 32 .")

