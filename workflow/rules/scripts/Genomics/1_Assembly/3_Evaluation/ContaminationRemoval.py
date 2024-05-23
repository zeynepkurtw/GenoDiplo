from snakemake.shell import shell

assembly = snakemake.input.assembly
assembly_gc_filtered = snakemake.output.assembly_gc_filtered
min_gc = snakemake.params.min_gc
max_gc = snakemake.params.max_gc


shell(f"""seqkit seq -g input.fasta\
| awk '$2 >= {min_gc} && $2 <= {max_gc}' \
| cut -f 1 \
| seqkit grep -f - {assembly} > {assembly_gc_filtered}""")
