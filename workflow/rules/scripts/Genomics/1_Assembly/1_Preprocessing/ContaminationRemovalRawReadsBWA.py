from snakemake.shell import shell
import os

os.environ['TMPDIR'] = '/path/to/large/disk/space'

contamination = snakemake.input.contamination
raw_reads = snakemake.input.raw_reads

threads = snakemake.params.threads

raw_reads_unmapped = snakemake.output.raw_reads_unmapped
raw_reads_unmapped_sorted = snakemake.output.raw_reads_unmapped_sorted
raw_reads_unmapped_fastq = snakemake.output.raw_reads_unmapped_fastq

shell(f"bwa mem -t {threads} {contamination} {raw_reads} | samtools view -b -f 4 -o {raw_reads_unmapped}")

shell(f"samtools sort -@ {threads} {raw_reads_unmapped} -o {raw_reads_unmapped_sorted}")
shell(f"samtools index -@ {threads} {raw_reads_unmapped_sorted}")
shell(f"samtools fastq -@ {threads} {raw_reads_unmapped_sorted} > {raw_reads_unmapped_fastq}")
shell(f"gzip -c {raw_reads_unmapped_fastq}")
#shell(f"samtools fastq -@ {threads} {raw_reads_unmapped_sorted} | gzip -c > {raw_reads_unmapped_fastq}")
