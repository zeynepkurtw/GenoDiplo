"""
    #prodigal
         expand("results/Genomics/2_Annotation/1_Structural/{assembler}/prodigal/genome.gff",
                assembler=["flye", "masurca"]),
         #glimmerhmm
         expand("results/Genomics/2_Annotation/1_Structural/{assembler}/glimmerhmm/genome.faa",
                assembler=["flye", "masurca"]),
         #diamond_blastp
       #  expand("results/Genomics/2_Annotation/2_Functional/{assembler}/{annotation}/genome_diplomonads.blastp",
        #        annotation=["glimmerhmm"],
         #       assembler=["flye", "masurca"]),
         #eggnogmapper
         expand("results/Genomics/2_Annotation/2_Functional/{assembler}/{annotation}/eggnogmapper_results.tsv",
                annotation=["glimmerhmm"],
                assembler=["flye", "masurca"]),
         #interproscan
         expand("results/Genomics/2_Annotation/2_Functional/{assembler}/{annotation}/interproscan_results.tsv",
                annotation=["glimmerhmm"],
                assembler=["flye", "masurca"]),
        #repeatmodeler
         expand("results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db-families.fasta",
                assembler=["flye", "masurca"]),
        #repeatmasker
            expand("results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RMasker",
                   assembler=["flye", "masurca"]),
        #tRNAscan
            expand("results/Genomics/1_Assembly/2_Assembly/{assembler}/genome.tRNAscan",
                   assembler=["flye", "masurca"]),
        #tRNAscan_cov
            expand("results/Genomics/1_Assembly/2_Assembly/{assembler}/sensitive_search/genome.tRNAscan_cov",
                   assembler=["flye", "masurca"]),
        #barrnap
            expand("results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/genome.rrna.gff",
                   assembler=["flye", "masurca"]),
        #cdhit
            expand("results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/genome_{n}.cdhit",
                   assembler=["flye", "masurca"],
                   n=[0.70, 0.75, 0.80, 0.85, 0.90, 0.95, 1]),
        #orthofinder
            #"results/ComparativeGenomics/2_SequenceSimilarityLevel/"
        #orthofinder_rerun


#expand("results/2_cdhit/{sp}_{n}.cdhit", n=config["seq_identity"], sp=config["species"])
#expand("results/7_tRNAscan/{sp}.tRNAscan",sp=["HIN", "muris", "wb", "spiro"]),
#expand("results/7_tRNAscan/sensitive_search/{sp}.cov.tRNAscan",sp=[ "muris", "wb", "spiro"]),


Genomics Analysis
    1: Hybrid Genome Assembly Workflow
        -Reads Preprocessing
        -Assembly
        -Evaluation
    2: Genome Annotation Workflow
        -Structural Annotation
        -Functional Annotation
"""

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

rule augustus:
    input:
        genome = "resources/{type}/hybrid_masurca_masked.fasta"
    output:
        directory("output/{type}/Augustus"),
        "output/{type}/Augustus/HIN.gff"
    params:
        num_threads = 30,
        species= "BUSCO_sp_tetrahymena_long"
    conda:
        "envs/blast.yaml"
    script:
        "scripts/augustus.py"

rule V3_busco_geneset:
    input:
        geneset = "resources/{type}/geneset/HIN.faa"
    output:
        directory("output/{type}/V3/HIN_geneset_V3_eukaryota/")
    params:
        lineage = "resources/3_BUSCO/V3/eukaryota_odb9",
        mode = "prot",
        num_threads = 30,
        out_name = "HIN_v3_euk"
    conda:
        "envs/blast.yaml"
    script:
        "scripts/busco_v3.py"

rule busco_transcriptome:
    input:
        trans = "resources/{type}/{assesment}/HIN_trans.fasta"
    output:
        directory("output/{type}/{assesment}/HIN_trans")
    params:
        lineage = "eukaryota_odb10",
        mode = "tran",
        tran = True,
        num_threads = 30,
        species= "tetrahymena"
    conda:
        "envs/blast.yaml"
    script:
        "scripts/busco.py"

rule busco_plot:
    input:
        "resources/{type}/summaries/"
    output:
        directory("resources/{type}/summaries/")
    conda:
        "envs/blast.yaml"
    shell:
        "generate_plot.py -wd {input}"

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
