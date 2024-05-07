from snakemake.shell import shell

assembly = snakemake.input.assembly
threads = snakemake.params.threads
outdir = snakemake.output.outdir

shell(f"quast.py {assembly} -o {outdir} --threads {threads} --eukaryote")
