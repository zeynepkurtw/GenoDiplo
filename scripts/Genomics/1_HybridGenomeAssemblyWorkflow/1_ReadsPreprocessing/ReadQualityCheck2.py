from snakemake.shell import shell

# Directories from Snakemake variables
r1 = snakemake.input.r1
r2 = snakemake.input.r2
threads = snakemake.params.threads
out_dir = snakemake.output.outdir

# Running FastQC on both R1 and R2 files and directing outputs to the output directory
shell(f"fastqc --threads {threads} {r1} -o {out_dir}")
shell(f"fastqc --threads {threads} {r2} -o {out_dir}")
