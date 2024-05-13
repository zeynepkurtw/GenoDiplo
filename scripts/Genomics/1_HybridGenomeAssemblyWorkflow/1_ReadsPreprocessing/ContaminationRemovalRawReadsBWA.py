from snakemake.shell import shell

contamination = snakemake.input.contamination
raw_reads = snakemake.input.raw_reads

threads = snakemake.params.threads

raw_reads_unmapped = snakemake.output.raw_reads_unmapped
raw_reads_unmapped_sorted = snakemake.output.raw_reads_unmapped_sorted
raw_reads_unmapped_fastq = snakemake.output.raw_reads_unmapped_fastq

#shell(f"bwa index {contamination}")
#shell(f"bwa mem -t {threads} {contamination} {raw_reads} | samtools view -b -f 4 -o {raw_reads_unmapped}")

#shell(f"samtools sort -@ {threads} {raw_reads_unmapped} -o {raw_reads_unmapped_sorted}")
#shell(f"samtools index -@ {threads} {raw_reads_unmapped_sorted}")
#shell(f"samtools fastq -@ {threads} {raw_reads_unmapped_sorted} -o {raw_reads_unmapped_fastq}")
#shell(f"gzip {raw_reads_unmapped_fastq}")



# Align reads, filter unmapped reads using samtools, and output in BAM format
shell(f"bwa mem -t {threads} {contamination} {raw_reads} | samtools view -b -f 4 -o {raw_reads_unmapped}.bam")

# Sort the BAM file
shell(f"samtools sort -@ {threads} {raw_reads_unmapped}.bam -o {raw_reads_unmapped_sorted}.bam")

# Index the sorted BAM file
shell(f"samtools index -@ {threads} {raw_reads_unmapped_sorted}.bam")

# Convert the sorted BAM file to FASTQ
shell(f"samtools fastq -@ {threads} {raw_reads_unmapped_sorted}.bam -o {raw_reads_unmapped_fastq}")

# Compress the FASTQ file
shell(f"gzip {raw_reads_unmapped_fastq}")
