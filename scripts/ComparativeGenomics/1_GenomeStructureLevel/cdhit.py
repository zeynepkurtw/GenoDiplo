from snakemake.shell import shell

genome = snakemake.input.genome
out = snakemake.output

#seq_identity = snakemake.params.seq_identity
threads = snakemake.params.threads
wildcards = snakemake.wildcards


#shell(f"""cd-hit -i {genome} -o {out} -c {wildcards.n} -T {threads}""")
shell(f"""cd-hit -i {genome} -o {out} -c {wildcards.n} -T {threads} -g 1""")