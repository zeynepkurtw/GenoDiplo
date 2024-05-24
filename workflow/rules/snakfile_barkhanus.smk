configfile: "config/config.yaml"

include: "rules/1_assembly.smk"
include: "rules/2_annotation.smk"
include: "rules/3_genome_level.smk"
include: "rules/4_homology_level.smk"
include: "rules/5_domain_level.smk"

rule all:
    input:
         #fastqc_before_trimming,
         "results/Genomics/1_Assembly/1_Preprocessing/fastqc_before_trimming",
         ##flye
         #expand("results/Genomics/1_Assembly/2_Assemblers/flye/"),
         #seqkit gc filter script
         "results/Genomics/1_Assembly/2_Assemblers/flye/raw/filtered/assembly.fasta",
         #blastn contamination detection
         expand("results/Genomics/1_Assembly/3_Evaluation/blastn/{assembler}/assembly.blastn",
                #assembler=[ "flye" ),
                assembler=["flye"]),
          #winnowmap evaluation
        # expand("results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/merlyDB",
         #       assembler=[ "flye"],
          #      genome=["Hexamita"]),
        # expand("results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/repetitive_k15.txt",
         #       assembler=[ "flye"],
          #      genome=["Hexamita"]),
        # expand("results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/{long_reads}.bam",
         #       assembler=[ "flye"],
          #      long_reads=["nanopore", "pacbio"]),
         #quast
         expand("results/Genomics/1_Assembly/3_Evaluation/quast/{assembler}/",
                assembler=[ "flye"]),
        #deeptools
         #expand("results/Genomics/1_Assembly/3_Evaluation/deeptools/{assembler}.png",
          #      assembler=[ "flye"]),
        #multiqc
         #expand("results/Genomics/1_Assembly/3_Evaluation/multiqc/{assembler}",
         # assembler=[ "flye"])

