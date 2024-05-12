from snakemake.shell import shell

contamination = snakemake.input.contamination
pair_reads_1 = snakemake.input.pair_reads_1
pair_reads_2 = snakemake.input.pair_reads_2
single_reads = snakemake.input.single_reads

paired = snakemake.params.get('paired', False)
threads = snakemake.params.threads

# Outputs for BAM files
paired_reads = snakemake.output.paired_reads
single_reads = snakemake.output.single_reads


# Build the Bowtie2 index for the contamination reference
#shell(f"bowtie2-build {contamination} {contamination}_index")

if paired:
    # Process Illumina paired-end reads
    shell(f"bowtie2 -p {threads} -x {contamination}_index -1 {pair_reads_1} -2 {pair_reads_2} \
          --no-head --no-sq | samtools view -bS - > {paired_reads}.bam")
    shell(f"samtools sort -@ {threads} {paired_reads} -o {paired_reads}_sorted.bam")
    shell(f"samtools index {paired_reads}_sorted.bam")
    shell(f"samtools fastq -@ {threads} {paired_reads}_sorted.bam -o {paired_reads}.fastq")
    shell(f"gzip -c {paired_reads}.fastq > {paired_reads}.fastq.gz")

else:
    # Process Pacbio and Nanopore reads
    shell(f"bowtie2 -p {threads} -x {contamination}_index -U {single_reads} \
          --no-head --no-sq | samtools view -bS - > {single_reads}.bam")
    shell(f"samtools sort -@ {threads} {single_reads} -o {single_reads}_sorted.bam")
    shell(f"samtools index {single_reads}_sorted.bam")
    shell(f"samtools fastq -@ {threads} {single_reads}_sorted.bam -o {single_reads}.fastq")
    shell(f"gzip -c {single_reads}.fastq > {single_reads}.fastq.gz")

