from snakemake.shell import shell

# Assuming the rule that calls this script is correctly defined as mentioned in previous communications:
r1 = snakemake.input.r1  # Input forward reads
r2 = snakemake.input.r2  # Input reverse reads
r1_p = snakemake.output.r1_p  # Output forward paired
r1_up = snakemake.output.r1_up  # Output forward unpaired
r2_p = snakemake.output.r2_p  # Output reverse paired
r2_up = snakemake.output.r2_up  # Output reverse unpaired
threads = snakemake.params.threads  # Number of threads

# Construct the Trimmomatic command correctly
shell(
    f"""trimmomatic PE -threads {threads} {r1} {r2} \
    {r1_p} {r1_up} {r2_p} {r2_up} \
    CROP:100 MINLEN:50"""
)
