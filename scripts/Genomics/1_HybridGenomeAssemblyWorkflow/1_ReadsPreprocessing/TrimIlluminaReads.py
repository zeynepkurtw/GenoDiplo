from snakemake.shell import shell

r1 = snakemake.input
r2 = snakemake.input
r1_u = snakemake.output #unique reads
r2_u = snakemake.output
r1_d = snakemake.output #duplicate reads
r2_d = snakemake.output
threads = snakemake.params.threads

shell(f"""trimmomatic PE -threads {threads} {r1} {r2} {r1_u} {r1_d} {r2_u} {r2_d} CROP:100 MINLEN:50""")

