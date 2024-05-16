from snakemake.shell import shell

proteome = snakemake.input.proteome
threads = snakemake.params.threads
outdir = snakemake.params.outdir
datadir = snakemake.params.datadir
diamond = snakemake.params.diamond

#shell(f"python emapper.py -i {proteome} --output {outdir} --cpu {threads} -m {diamond} --data_dir {datadir}")
shell(f"python emapper.py -i {proteome} --output {outdir} --cpu {threads} -m {diamond}")
