from snakemake.shell import shell

genome = snakemake.input

threads = snakemake.params.threads
paired = snakemake.params.get('paired', False)

bam = snakemake.output
bai = snakemake.output

if paired:
    ill_R1 = snakemake.input.ill_R1
    ill_R2 = snakemake.input.ill_R2
    shell(f"""bwa mem -t {threads} {genome} {ill_R1} {ill_R2} | samtools sort -o {bam} -@ {threads}""")
    shell(f"""samtools index {bam} {bai} -@ {threads}""")
else:
    single = snakemake.input.single
    shell(f"""bwa mem -t {threads} {genome} {single} | samtools sort -o {bam} -@ {threads}""")
    shell(f"""samtools index {bam} {bai} -@ {threads} """)