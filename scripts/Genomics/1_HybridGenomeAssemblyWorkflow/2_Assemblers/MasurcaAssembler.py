from snakemake.shell import shell

config = snakemake.input.config
path = snakemake.params.path
out_dir = snakemake.output.out_dir

#MaSuRCA (FLYE_ASSEMBLY = 1, SOAP_ASSEMBLY=0)
#shell(f"masurca {config} --path {path}")
shell(f"masurca {config}")
shell(f"bash assemble.sh > {out_dir}")