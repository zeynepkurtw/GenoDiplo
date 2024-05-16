from snakemake.shell import shell

proteome = snakemake.input.proteome
threads = snakemake.params.threads
outdir = snakemake.params.outdir

#remove the stars representing the stop codons
shell(f"""sed 's/*//' {proteome} > proteome_.faa""")
shell(f"""interproscan.sh -i proteome_.faa -d {outdir} -f gff3,tsv,json -iprlookup -goterms --pathways -cpu {threads} """)