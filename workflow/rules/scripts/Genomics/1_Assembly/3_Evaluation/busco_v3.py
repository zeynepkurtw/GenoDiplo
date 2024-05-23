from snakemake.shell import shell

out = snakemake.output
geneset = snakemake.input.geneset

mode= snakemake.params.mode
lineage = snakemake.params.lineage
num_threads= snakemake.params.num_threads
out_name = snakemake.params.out_name


shell(f"""run_BUSCO.py -i {geneset} -l {lineage} -m {mode} -o {out_name} -c {num_threads}""")
