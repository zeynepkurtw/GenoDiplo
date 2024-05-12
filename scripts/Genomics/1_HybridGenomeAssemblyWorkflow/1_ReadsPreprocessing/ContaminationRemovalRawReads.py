from snakemake.shell import shell

contamination = snakemake.input.contamination
paired_reads_1 = snakemake.input.paired_reads_1
paired_reads_2 = snakemake.input.paired_reads_2
single_reads = snakemake.input.single_reads

paired = snakemake.params.get('paired', False)
threads = snakemake.params.threads

# Outputs for BAM files
paired_reads_bam = snakemake.output.paired_reads_bam
single_reads_bam = snakemake.output.single_reads_bam


# Build the Bowtie2 index for the contamination reference
#shell(f"bowtie2-build {contamination} {contamination}_index")

if paired:
    # Process Illumina paired-end reads
    shell(f"bowtie2 -p {threads} -x {contamination}_index -1 {paired_reads_1} -2 {paired_reads_2} \
          --no-head --no-sq | samtools view -bS - > {paired_reads_bam}")
    shell(f"samtools sort -@ {threads} {paired_reads_bam} -o {paired_reads_bam}_sorted.bam")
    shell(f"samtools index {paired_reads_bam}_sorted.bam")

else:
    # Process Pacbio and Nanopore reads
    shell(f"bowtie2 -p {threads} -x {contamination}_index -U {single_reads} \
          --no-head --no-sq | samtools view -bS - > {single_reads_bam}")
    shell(f"samtools sort -@ {threads} {single_reads_bam} -o {single_reads_bam}_sorted.bam")
    shell(f"samtools index {single_reads_bam}_sorted.bam")

