from snakemake.shell import shell
import os

bam = snakemake.output.bam
bai = snakemake.output.bai

num_threads = snakemake.params.num_threads
index = os.path.commonprefix(snakemake.input.index).rstrip(".")
illumina_paired = snakemake.input.illumina_paired

shell(f"""bowtie2 -p {num_threads} {illumina_paired} -x {index} | samtools sort -o {bam}""")
shell(f"""samtools index {bam} {bai}""")