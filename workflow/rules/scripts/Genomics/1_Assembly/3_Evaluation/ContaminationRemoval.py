from snakemake.shell import shell

assembly = snakemake.input.assembly
assembly_gc_filtered = snakemake.output.assembly_gc_filtered
gc_stats = snakemake.output.gc_stats

min_gc = snakemake.params.min_gc
max_gc = snakemake.params.max_gc


shell(f"seqkit fx2tab -g {assembly} | cut -f 1,4 > {gc_stats}")
shell(f"""awk '$2 >= {min_gc} && $2 <= {max_gc}' {gc_stats} \
| cut -f 1 \
| seqkit grep -f - {assembly} > {assembly_gc_filtered}""")