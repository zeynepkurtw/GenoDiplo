from snakemake.shell import shell

reads = snakemake.input.reads
output = snakemake.output

shell(f"fastqc --threads 8 {reads} --outdir {output}")

