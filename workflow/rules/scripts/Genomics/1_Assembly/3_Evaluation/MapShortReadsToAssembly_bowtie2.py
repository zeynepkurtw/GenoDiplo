from snakemake.shell import shell
import os


threads = snakemake.params.threads
index = os.path.commonprefix(snakemake.input.index).rstrip(".")
paired = snakemake.params.get('paired', False)

bam = snakemake.output.bam

#shell(f"""bowtie2 -p {threads} -1 {ill_R1} -2 {ill_R2} -x {index} | samtools sort -o {bam}""")
#shell(f"""samtools index {bam} {bai}""")


if paired:
    ill_R1 = snakemake.input.ill_R1
    ill_R2 = snakemake.input.ill_R2
    shell(f"""bowtie2 -p {threads} -1 {ill_R1} -2 {ill_R2} -x {index} 2>bowtie2_paired.log | \
        samtools sort -o {bam} 2>samtools_paired.log""")
    shell(f"""samtools index {bam}""")
else:
    single = snakemake.input.single
    shell(f"""bowtie2 -p {threads} {single} -x {index} 2>bowtie2_single.log | \
        samtools sort -o {bam} 2>samtools_single.log""")
    shell(f"""samtools index {bam}""")