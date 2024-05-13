from snakemake.shell import shell

num_threads = snakemake.params.num_threads
genome = snakemake.input.genome
ill_R1 = snakemake.input.ill_R1
ill_R2 = snakemake.input.ill_R2

bam = snakemake.output.bam
bai = snakemake.output.bai

shell(f"""bowtie2 -p {num_threads} -1 {ill_R1} -2 {ill_R2} -x {genome}_index | samtools sort -o {bam}""")
shell(f"""samtools index {bam} {bai}""")