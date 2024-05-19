from snakemake.shell import shell

#input
genome = snakemake.input.genome
long_read = snakemake.input.long_read
merylDB= snakemake.input.merylDB
repetitive_k15 = snakemake.input.repetitive_k15
#output
sorted_bam= snakemake.output.sorted_bam
#params
threads = snakemake.params.threads

shell(f"""winnowmap -W {repetitive_k15} -ax map-ont {genome} {long_read} | samtools sort -o {sorted_bam} -""")
shell(f"""samtools index {sorted_bam}""")
