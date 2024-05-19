from snakemake.shell import shell
import os


threads = snakemake.params.threads
index = os.path.commonprefix(snakemake.input.index).rstrip(".")
paired = snakemake.params.get('paired', False)

sorted_bam = snakemake.output.sorted_bam


if paired:
    ill_R1 = snakemake.input.ill_R1
    ill_R2 = snakemake.input.ill_R2
    shell(f"""bowtie2 -p {threads} -1 {ill_R1} -2 {ill_R2} -x {index} | \
        samtools sort -o {sorted_bam} -""")
    shell(f"""samtools index {sorted_bam}""")

else:
    single = snakemake.input.single
    shell(f"""bowtie2 -p {threads} {single} -x {index} | \
        samtools sort -o {sorted_bam} -""")
    shell(f"""samtools index {sorted_bam}""")