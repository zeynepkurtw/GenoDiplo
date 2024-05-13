from snakemake.shell import shell
import os

# Directories from Snakemake variables
input_dir = snakemake.input.outdir
r1 = snakemake.input.r1
r2 = snakemake.input.r2

# Ensure the output directory exists
os.makedirs(out_dir, exist_ok=True)

# Running FastQC on both R1 and R2 files and directing outputs to the output directory
shell(f"fastqc --threads 32 {r1} -o {out_dir}")
shell(f"fastqc --threads 32 {r2} -o {out_dir}")
