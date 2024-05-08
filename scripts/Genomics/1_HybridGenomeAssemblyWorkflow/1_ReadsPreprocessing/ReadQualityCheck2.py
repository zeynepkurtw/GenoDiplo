from snakemake.shell import shell

r1 = snakemake.input.r1
r2 = snakemake.input.r2
outdir = snakemake.output.outdir

shell(f"fastqc --threads 8 {r1} {r2} --outdir {outdir}")

