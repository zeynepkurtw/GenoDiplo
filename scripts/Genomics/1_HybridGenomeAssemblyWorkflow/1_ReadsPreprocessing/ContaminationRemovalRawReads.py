from snakemake.shell import shell
import os

paired = snakemake.params.get('paired', False)
threads = snakemake.params.threads
index = os.path.commonprefix(snakemake.input.index).rstrip(".")


# Build the Bowtie2 index for the contamination reference
#shell(f"bowtie2-build {contamination} {contamination}_index")

if paired:
    ill_R1 = snakemake.input.ill_R1
    ill_R2 = snakemake.input.ill_R2
    contaminated_short = snakemake.output.contaminated_short
    clean_ill = snakemake.output.clean_ill
    # Process Illumina paired-end reads
    # Map reads using Bowtie2 and save unmapped reads into separate files
    shell(f"bowtie2 -p {threads} -x {index} -1 {ill_R1} -2 {ill_R2} \
          --un-conc {clean_ill} \
          --no-head --no-sq | samtools view -bS - > {contaminated_short}.bam")
    # Sort the mapped reads BAM file
    shell(f"samtools sort -@ {threads} {contaminated_short}.bam -o {contaminated_short}_sorted.bam")
    # Index the sorted BAM file
    shell(f"samtools index {contaminated_short}_sorted.bam")
    # The unmapped reads are automatically saved by Bowtie2 using the --un-conc option in {clean}_R1 and {clean}_R2
    # Optionally, if you want to compress these unmapped reads
    shell(f"gzip -c {clean_ill}_R1 > {clean_ill}_R1.fastq.gz")
    shell(f"gzip -c {clean_ill}_R2 > {clean_ill}_R2.fastq.gz")


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



