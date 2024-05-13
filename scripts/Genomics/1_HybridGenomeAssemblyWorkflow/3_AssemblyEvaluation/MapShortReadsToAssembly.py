from snakemake.shell import shell


genome = snakemake.input.genome
ill_R1 = snakemake.input.ill_R1
ill_R2 = snakemake.input.ill_R2
threads = snakemake.params.threads

genome_short = snakemake.output.genome_short

shell(f"""bowtie2 -p {threads} -1 {ill_R1}_R1 -2 {ill_R2}_R2 -x {genome}_index | samtools view -bS - > {genome_short}.bam""")
shell(f"samtools sort -@ {threads} {genome_short}.bam -o {genome_short}_sorted.bam")
shell(f"samtools index {genome_short}_sorted.bam")