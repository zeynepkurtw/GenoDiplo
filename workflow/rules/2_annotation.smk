rule prodigal:
    input:
         genome="results/Genomics/1_Assembly/2_Assembly/pilon/{assembler}/assembly_polished.fasta",
    output:
          gff="results/Genomics/2_Annotation/1_Structural/prodigal/{assembler}/genome.gff",
          faa="results/Genomics/2_Annotation/1_Structural/prodigal/{assembler}/genome.faa",
          ffn="results/Genomics/2_Annotation/1_Structural/prodigal/{assembler}/genome.ffn",
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/2_Annotation/1_Structural/ProdigalAnnotation.py"
rule glimmerhmm:
    input:
        training_genes="resources/Train_GlimmerHMM/training_genes.fasta",
        genome= "results/Genomics/1_Assembly/2_Assembly/pilon/{assembler}/assembly_polished.fasta",
    params:
          n=150,
          v=50
    output:
        trained_genes = "results/Genomics/2_Annotation/1_Structural/glimmerhmm/{assembler}/genome_trained_genes.hmm",
        gff="results/Genomics/2_Annotation/1_Structural/{assembler}/genome.gff",
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/2_Annotation/1_Structural/GlimmerHMMAnnotation.py"

#Functional Annotation
rule makeblastdb:
    input:
        "results/Genomics/2_Annotation/1_Structural/{assembler}/{annotation}/genome.faa"
    output:
        multiext("results/Genomics/2_Annotation/1_Structural/{assembler}/{annotation}/genome",
            ".ndb",
            ".nhr",
            ".nin",
            ".not",
            ".nsq",
            ".ntf",
            ".nto")
    params:
        outname="results/{type}/db/{db}"
    conda:
        "envss/blast.yaml"
    shell:
        'makeblastdb -dbtype nucl -in {input} -out {params.outname}'

rule diamond_blastp:
    input:
         genome="results/Genomics/2_Annotation/1_Structural/{assembler}/{annotation}/genome.faa"
    output:
          "results/Genomics/2_Annotation/2_Functional/{assembler}/{annotation}/genome_diplomonads.blastp"
    params:
          db_prefix="path/to/database_prefix",
          outfmt=6,
          threads=32,
          max_target_seqs=500,
          max_hsps=1,
          more_sensitive="",
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/2_Annotation/2_Functional/Diamond.py"
rule eggnogmapper:
    input:
         proteome="results/Genomics/2_Annotation/1_Structural/{assembler}/{annotation}/genome.faa"
    output:
          "results/Genomics/2_Annotation/2_Functional/{assembler}/{annotation}/eggnogmapper_results.tsv"
    params:
          threads=32,
          diamond="diamond",
          outdir="results/Genomics/2_Annotation/2_Functional/{assembler}/{annotation}/",
          datadir="path/to/data",

    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/2_Annotation/2_Functional/Eggnogmapper.py"
rule interproscan:
    input:
         proteome="results/Genomics/2_Annotation/1_Structural/{assembler}/{annotation}/genome.faa"
    output:
          "results/Genomics/2_Annotation/2_Functional/{assembler}/{annotation}/interproscan_results.tsv"
    params:
          threads=32,
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/2_Annotation/2_Functional/Interproscan.py"
