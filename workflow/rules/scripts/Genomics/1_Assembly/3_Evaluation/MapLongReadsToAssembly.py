from snakemake.shell import shell

#input
genome = snakemake.input.genome
long_read = snakemake.input.long_read
merylDB= snakemake.input.merylDB
repetitive_k15 = snakemake.input.repetitive_k15
#output
bam= snakemake.output.bam
bai = snakemake.output.bai
#params
threads = snakemake.params.threads

shell(f"""winnowmap -W {repetitive_k15} -ax map-ont {genome} {long_read} | samtools sort -o {bam}""")
shell(f"""samtools index {bam} {bai} """)
