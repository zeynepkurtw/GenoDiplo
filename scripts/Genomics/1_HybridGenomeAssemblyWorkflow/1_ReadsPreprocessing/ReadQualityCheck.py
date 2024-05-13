from snakemake.shell import shell

input_dir = snakemake.input.input_dir
out_dir = snakemake.output.out_dir

#shell(f"cd {input_dir}")
#shell(f"fastqc --threads 32 .")

shell(f"mkdir {out_dir}")
shell(f"fastqc --threads 32 {input_dir}/*.fastq.gz -o {out_dir}")
