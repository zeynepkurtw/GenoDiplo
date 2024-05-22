from snakemake.shell import shell


run1 = snakemake.input.run1
run2 = snakemake.input.run2
run3 = snakemake.input.run3
pac = snakemake.input.pac
nano = snakemake.input.nano

out = snakemake.output.out
outraw = snakemake.output.outraw
threads = snakemake.params.threads

shell(f"""plotCoverage -b {run1} {run2} {run3} {pac} {nano} \
-o {out} -p {threads} --verbose --outRawCounts {outraw}""")
