from snakemake.shell import shell

contamination = snakemake.input.contamination
raw_reads = snakemake.input.raw_reads

threads = snakemake.params.threads

raw_reads_unmapped = snakemake.output.raw_reads_unmapped
raw_reads_unmapped_sorted = snakemake.output.raw_reads_unmapped_sorted
raw_reads_unmapped_fastq = snakemake.output.raw_reads_unmapped_fastq

shell(f"bwa index {contamination}")
shell(f"bwa mem -t {threads} {contamination} {raw_reads} | samtools view -b -f 4 -o {raw_reads_unmapped}")

shell(f"samtools sort -@ {threads} {raw_reads_unmapped} -o {raw_reads_unmapped_sorted}")
shell(f"samtools index -@ {threads} {raw_reads_unmapped_sorted}")
shell(f"samtools fastq -@ {threads} {raw_reads_unmapped_sorted} -o {raw_reads_unmapped_fastq}")
shell(f"gzip {raw_reads_unmapped_fastq}")
