from snakemake.shell import shell

reads = snakemake.input.reads
outdir = snakemake.params.outdir


shell(f"fastqc --threads 32 {reads} --outdir {outdir}")

