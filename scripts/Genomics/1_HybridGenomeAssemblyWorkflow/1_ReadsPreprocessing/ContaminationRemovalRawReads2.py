from snakemake.shell import shell

contamination = snakemake.input.contamination
# Inputs for different technologies
illumina_reads_1 = snakemake.input.illumina_reads_1
illumina_reads_2 = snakemake.input.illumina_reads_2
nanopore_reads = snakemake.input.nanopore_reads
pacbio_reads = snakemake.input.pacbio_reads

threads = snakemake.params.threads

# Outputs for BAM files
illumina_bam = snakemake.output.illumina_bam
nanopore_bam = snakemake.output.nanopore_bam
pacbio_bam = snakemake.output.pacbio_bam

# Build the Bowtie2 index for the contamination reference
shell(f"bowtie2-build {contamination} {contamination}_index")

# Process Illumina paired-end reads
shell(f"bowtie2 -p {threads} -x {contamination}_index -1 {illumina_reads_1} -2 {illumina_reads_2} \
      --no-head --no-sq | samtools view -bS - > {illumina_bam}")
shell(f"samtools sort -@ {threads} {illumina_bam} -o {illumina_bam}_sorted.bam")
shell(f"samtools index {illumina_bam}_sorted.bam")

# Process Nanopore reads
shell(f"bowtie2 -p {threads} -x {contamination}_index -U {nanopore_reads} \
      --no-head --no-sq | samtools view -bS - > {nanopore_bam}")
shell(f"samtools sort -@ {threads} {nanopore_bam} -o {nanopore_bam}_sorted.bam")
shell(f"samtools index {nanopore_bam}_sorted.bam")

# Process PacBio reads
shell(f"bowtie2 -p {threads} -x {contamination}_index -U {pacbio_reads} \
      --no-head --no-sq | samtools view -bS - > {pacbio_bam}")
shell(f"samtools sort -@ {threads} {pacbio_bam} -o {pacbio_bam}_sorted.bam")
shell(f"samtools index {pacbio_bam}_sorted.bam")
