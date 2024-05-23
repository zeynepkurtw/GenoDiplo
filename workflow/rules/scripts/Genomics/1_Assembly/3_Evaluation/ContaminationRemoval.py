from snakemake.shell import shell

assembly = snakemake.input.assembly
assembly_gc_filtered = snakemake.output.assembly_gc_filtered
min_gc = snakemake.params.min_gc
max_gc = snakemake.params.max_gc


shell(f"""seqkit fx2tab -g {assembly} \
| awk '$NF >= {min_gc} && $NF <= {max_gc}' \
| cut -f 1 \
| seqkit grep -f - {assembly} > {assembly_gc_filtered}""")
