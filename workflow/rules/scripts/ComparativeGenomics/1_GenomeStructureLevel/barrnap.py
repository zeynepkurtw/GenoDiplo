from snakemake.shell import shell

genome = snakemake.input.genome
#fasta= snakemake.output.fasta
gff = snakemake.output.gff

#shell(f"""barrnap --kingdom euk --quiet {genome} --outseq {fasta} output.fasta > {gff}""")
shell(f"""barrnap --kingdom euk --quiet {genome} > {gff}""")
