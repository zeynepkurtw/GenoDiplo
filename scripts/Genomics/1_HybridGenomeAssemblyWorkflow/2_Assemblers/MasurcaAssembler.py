from snakemake.shell import shell

config = snakemake.input.config
path = snakemake.params.path
outdir = snakemake.output.outdir

#MaSuRCA (FLYE_ASSEMBLY = 1, SOAP_ASSEMBLY=0)
shell(f"masurca {config} --path {path}")
shell(f"bash assemble.sh > {outdir}")