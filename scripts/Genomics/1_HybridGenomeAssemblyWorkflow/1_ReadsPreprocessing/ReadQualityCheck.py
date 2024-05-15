from snakemake.shell import shell

input_dir = snakemake.input.input_dir
threads = snakemake.params.threads
out_dir = snakemake.output.out_dir

shell(f"fastqc --threads {threads} {input_dir}/*.fastq.gz -o {out_dir}")
