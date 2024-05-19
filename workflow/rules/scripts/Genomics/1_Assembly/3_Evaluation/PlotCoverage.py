from snakemake.shell import shell

pacbio = snakemake.input.pacbio
nanopore = snakemake.input.nanopore
run1 = snakemake.input.run1
run2 = snakemake.input.run2
run3 = snakemake.input.run3

out = snakemake.output.out
outraw = snakemake.output.outraw
threads = snakemake.params.threads

ill1_P = snakemake.params.ill1_P
ill2_P = snakemake.params.ill2_P
ill3_P = snakemake.params.ill3_P
pac = snakemake.params.pac
nano = snakemake.params.nano

shell(f"""plotCoverage -b {run1} {run2} {run3} {pacbio} {nanopore}\
 --labels {ill1_P} {ill2_P} {ill3_P} {pac} {nano}\
  -o {out} -p {threads} --verbose --outRawCounts {outraw}""")
