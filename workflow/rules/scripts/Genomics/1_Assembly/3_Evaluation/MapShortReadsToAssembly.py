from snakemake.shell import shell
import os

threads = snakemake.params.threads
paired = snakemake.params.get('paired', False)
index = os.path.commonprefix(snakemake.input.index).rstrip(".")

bam = snakemake.output

if paired:
    ill_R1 = snakemake.input.ill_R1
    ill_R2 = snakemake.input.ill_R2
    shell(f"""bwa mem -t {threads} {index} {ill_R1} {ill_R2} | samtools sort -o {bam} -@ {threads}""")
    shell(f"""samtools index {bam} -@ {threads}""")
else:
    single = snakemake.input.single
    shell(f"""bwa mem -t {threads} {index} {single} | samtools sort -o {bam} -@ {threads}""")
    shell(f"""samtools index {bam} -@ {threads} """)