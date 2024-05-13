from snakemake.shell import shell
import os

paired = snakemake.params.get('paired', False)
threads = snakemake.params.threads
index = os.path.commonprefix(snakemake.input.index).rstrip(".")

if paired:
    ill_R1 = snakemake.input.ill_R1
    ill_R2 = snakemake.input.ill_R2
    contaminated_short = snakemake.output.contaminated_short
    clean_ill_R1 = snakemake.output.clean_ill_R1
    clean_ill_R2 = snakemake.output.clean_ill_R2

    shell(f"bowtie2 -p {threads} -x {index} -1 {ill_R1} -2 {ill_R2} \
    --un-conc {clean_ill_R1},{clean_ill_R2} \
    --no-head --no-sq | samtools view -bS - > {contaminated_short}.bam")

    shell(f"samtools sort -@ {threads} {contaminated_short}.bam -o {contaminated_short}_sorted.bam")
    shell(f"samtools index {contaminated_short}_sorted.bam")

    shell(f"gzip -c {clean_ill_R1} > {clean_ill_R1}.fastq.gz")
    shell(f"gzip -c {clean_ill_R2} > {clean_ill_R2}.fastq.gz")



else:
    long_reads = snakemake.input.long_reads
    contaminated_long = snakemake.output.contaminated_long
    clean_long = snakemake.output.clean_long
    # Align Nanopore reads and save unmapped reads
    shell(f"bowtie2 -p {threads} -x {index} -U {long_reads} \
    --un {clean_long} \
    --no-head --no-sq | samtools view -bS - > {contaminated_long}.bam")

    shell(f"samtools sort -@ {threads} {contaminated_long}.bam -o {contaminated_long}_sorted.bam")
    shell(f"samtools index {contaminated_long}_sorted.bam")
    shell(f"gzip -c {clean_long}_unmapped.fastq > {clean_long}_unmapped.fastq.gz")



