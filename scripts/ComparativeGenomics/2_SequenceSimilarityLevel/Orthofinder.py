from snakemake.shell import shell

# input,output
proteome = snakemake.input.proteome
out = snakemake.output



# -og : stop after inferring orthogroups
shell(f"""orthofinder -f {proteome} -o {out} -og -S blast""")
