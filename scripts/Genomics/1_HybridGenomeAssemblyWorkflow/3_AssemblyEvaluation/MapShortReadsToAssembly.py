from snakemake.shell import shell


genome = snakemake.input.genome
ill_R1 = snakemake.input.ill_R1
ill_R2 = snakemake.input.ill_R2
threads = snakemake.params.threads

bam = snakemake.output.bam
bai = snakemake.output.bai


shell(f"""bowtie2 -p {threads} -1 {ill_R1} -2 {ill_R2} -x {genome} | samtools sort -o {bam}""")
shell(f"""samtools index {bam} {bai}""")

