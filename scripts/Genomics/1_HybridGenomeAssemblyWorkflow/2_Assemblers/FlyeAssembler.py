from snakemake.shell import shell

input = snakemake.input
output = snakemake.output
genome_size = snakemake.params.genome_size
threads = snakemake.params.threads

#only nanopore reads
shell(f"""flye --nano-raw {input} --genome-size {genome_size} --threads {threads} -o {output}""")
