from snakemake.shell import shell

input_dir = snakemake.input.input_dir
out = snakemake.output[0]

#shell(f"cd {input_dir}")
#shell(f"fastqc --threads 32 .")

shell(f"fastqc --threads 32 {input_dir}/*.fastq.gz")
