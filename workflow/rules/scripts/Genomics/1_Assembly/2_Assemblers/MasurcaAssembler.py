from snakemake.shell import shell

config = snakemake.input.config
path = snakemake.params.path
out_dir = snakemake.output.out_dir

shell(f"mkdir -p {out_dir}")
shell(f"cp {config} {out_dir}")
shell(f"cd {out_dir}")
shell(f"masurca {config}")
shell(f"bash assemble.sh")
