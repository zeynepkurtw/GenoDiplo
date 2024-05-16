from snakemake.shell import shell

# Assuming the rule that calls this script is correctly defined as mentioned in previous communications:
r1 = snakemake.input.r1  # Input forward reads
r2 = snakemake.input.r2  # Input reverse reads
r1_u = snakemake.output.r1_u  # Output forward paired
r1_d = snakemake.output.r1_d  # Output forward unpaired
r2_u = snakemake.output.r2_u  # Output reverse paired
r2_d = snakemake.output.r2_d  # Output reverse unpaired
threads = snakemake.params.threads  # Number of threads

# Construct the Trimmomatic command correctly
shell(
    f"""trimmomatic PE -threads {threads} {r1} {r2} \
    {r1_u} {r1_d} {r2_u} {r2_d} \
    CROP:100 MINLEN:50"""
)
