from snakemake.shell import shell

# Input files
assembly = snakemake.input.assembly
#ill_run1_R1 = snakemake.input.ill_run1_R1
ill_run1 = snakemake.input.ill_run1
ill_run2 = snakemake.input.ill_run2
ill_run3 = snakemake.input.ill_run3
ill_run1_R1_up = snakemake.input.ill_run1_R1_up
ill_run1_R2_up = snakemake.input.ill_run1_R2_up
ill_run2_R1_up = snakemake.input.ill_run2_R1_up
ill_run2_R2_up = snakemake.input.ill_run2_R2_up
ill_run3_R1_up = snakemake.input.ill_run3_R1_up
ill_run3_R2_up = snakemake.input.ill_run3_R2_up

# Parameters
threads = snakemake.params.threads

# Output file
polished_assembly = snakemake.output.polished_assembly

shell(f"""pilon \
--genome {assembly} \
--frags {ill_run1} \
--frags {ill_run2} \
--frags {ill_run3} \
--frags {ill_run1_R1_up} \
--frags {ill_run1_R2_up} \
--frags {ill_run2_R1_up} \
--frags {ill_run2_R2_up} \
--frags {ill_run3_R1_up} \
--frags {ill_run3_R2_up} \
--output {polished_assembly} \
--threads {threads}""")
