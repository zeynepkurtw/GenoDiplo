from snakemake.shell import shell

# Input files
assembly = snakemake.input.assembly
illumina_run1_R1 = snakemake.input.illumina_run1_R1
illumina_run1_R2 = snakemake.input.illumina_run1_R2
illumina_run2_R1 = snakemake.input.illumina_run2_R1
illumina_run2_R2 = snakemake.input.illumina_run2_R2
illumina_run3_R1 = snakemake.input.illumina_run3_R1
illumina_run3_R2 = snakemake.input.illumina_run3_R2

# Parameters
threads = snakemake.params.threads

# Output file
polished_assembly = snakemake.output.polished_assembly

# Run Pilon
shell(f"""
    java -Xmx16G -jar /path/to/pilon.jar \
    --genome {assembly} \
    --frags {illumina_run1_R1},{illumina_run1_R2} \
    --frags {illumina_run2_R1},{illumina_run2_R2} \
    --frags {illumina_run3_R1},{illumina_run3_R2} \
    --output {polished_assembly} \
    --threads {threads}
""")
