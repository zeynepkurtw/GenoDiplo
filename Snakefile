configfile: "env/config.yaml"

rule all:
    input:
         #fastqc
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/fastqc",
         #trimmomatic
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/trimmomatic/{run}_R1.unique.trimmed.fastq",
                run=["illumina_run1", "illumina_run2", "illumina_run3"]),
         #ContaminationDetection.py
         #bwa
         #expand("resources/RawData/DNA/clean/{DNAseq}.clean.fastq.gz",
         #       DNAseq=config["reads"]),
         #bowtie2_clean_paired_reads
            expand("resources/RawData/DNA/clean/short/{sample}_R1.fastq.gz",
                   sample=["illumina_run1", "illumina_run2", "illumina_run3"]),
         #bowtie2_clean_single_reads
            expand("resources/RawData/DNA/clean/long/{sample}.fastq.gz",
                   sample=["nanopore", "pacbio"]),
         #flye
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/flye/flye_{genome}.fasta",
                genome=["Hexamita"]),
         #masurca
         #expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/masurca/masurca_{genome}.fasta",
          #      genome=["Hexamita"]),
         #polca
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}_polished_{genome}.fasta",
                assembler=["flye", "masurca"],
                genome=["Hexamita"]),
         #quast
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/quast_report/",
                assembler=["flye", "masurca"],
                genome=["Hexamita"]),
         #bowtie2_paired_reads_evaluation
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{assembler}_polished_{genome}/{sample}.bam",
                assembler=["flye", "masurca"],
                genome=["Hexamita"],
                sample=["illumina_run1", "illumina_run2", "illumina_run3"]),
         #meryl_evaluation
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/merlyDB",
                assembler=["flye", "masurca"],
                genome=["Hexamita"]),
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/repetitive_k15.txt",
                assembler=["flye", "masurca"],
                genome=["Hexamita"]),
         #winnowmap_evaluation
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/{long_reads}.bam",
                assembler=["flye", "masurca"],
                genome=["Hexamita"],
                long_reads=["nanopore", "pacbio"]),

         #prodigal
         expand("output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/prodigal/{genome}.gff",
                assembler=["flye", "masurca"],
                genome=["Hexamita"]),
         #glimmerhmm
         expand("output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/glimmerhmm/{genome}.faa",
                assembler=["flye", "masurca"],
                genome=["Hexamita"]),
         #diamond_blastp
         expand("output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/{genome}_diplomonads.blastp",
                assembler=["flye"],
                annotation=["glimmerhmm"],
                genome=["Hexamita"]),
         #eggnogmapper
         expand("output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/{genome}_eggnogmapper_results.tsv",
                assembler=["flye"],
                annotation=["glimmerhmm"],
                genome=["Hexamita"]),
         #interproscan
         expand("output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/{genome}_diplomonads_interproscan_results.tsv",
                assembler=["flye"],
                annotation=["glimmerhmm"],
                genome=["Hexamita"]),

        #repeatmodeler
         expand("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_RModeler/{genome}_db-families.fasta",
               assembler=["flye"],
               genome=["Hexamita"]),
        #repeatmasker
            expand("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_RMasker",
                assembler=["flye"],
                genome=["Hexamita"]),
        #tRNAscan
            expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{genome}.tRNAscan",
                assembler=["flye"],
                genome=["Hexamita"]),
        #tRNAscan_cov
            expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/sensitive_search/{genome}.tRNAscan_cov",
                assembler=["flye"],
                genome=["Hexamita"]),
        #barrnap
            expand("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}.rrna.gff",
                assembler=["flye"],
                genome=["Hexamita"]),
        #cdhit
            expand("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_{n}.cdhit",
                assembler=["flye"],
                genome=["Hexamita"],
                   n=[0.70, 0.75, 0.80, 0.85, 0.90, 0.95, 1]),
        #orthofinder
            #"output/ComparativeGenomics/2_SequenceSimilarityLevel/"
        #orthofinder_rerun


#expand("output/2_cdhit/{sp}_{n}.cdhit", n=config["seq_identity"], sp=config["species"])
#expand("output/7_tRNAscan/{sp}.tRNAscan",sp=["HIN", "muris", "wb", "spiro"]),
#expand("output/7_tRNAscan/sensitive_search/{sp}.cov.tRNAscan",sp=[ "muris", "wb", "spiro"]),

"""
Genomics Analysis
    1: Hybrid Genome Assembly Workflow 
        -Reads Preprocessing
        -Assembly
        -Evaluation
    2: Genome Annotation Workflow
        -Structural Annotation
        -Functional Annotation
"""

#Hybrid Genome Assembly Workflow
#Reads Preprocessing
rule fastqc_before_trimming:
    input:
         input_dir = "resources/RawData/DNA/raw/",
    output:
        directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/fastqc"),
    params:
        threads=32,
    conda:
         "env/genomics.yaml",
    script:
         "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ReadQualityCheck.py"


rule trimmomatic:
    input:
         r1="resources/RawData/DNA/raw/{run}_R1.fastq.gz",
         r2="resources/RawData/DNA/raw/{run}_R2.fastq.gz"
    params:
            threads=32,
    output:
          r1_u="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/trimmomatic/{run}_R1.unique.trimmed.fastq",
          r2_u="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/trimmomatic/{run}_R2.unique.trimmed.fastq",
          r1_d="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/trimmomatic/{run}_R1.duplicate.trimmed.fastq",
          r2_d="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/trimmomatic/{run}_R2.duplicate.trimmed.fastq"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/TrimIlluminaReads.py"

rule fastqc_after_trimming:
    input:
         r1="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{seq}.unique.trimmed.fastq",
         r2="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{seq}.duplicate.trimmed.fastq",
         outdir="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing"
    output:
          html="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{seq}.unique.trimmed_fastqc.html",
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ReadQualityCheck2.py"

#rule calculatereadmeanstdev
"""rule bwa_index:
    input:
        "resources/Contamination/all_contaminated.fasta"
    output:
        multiext(
            "resources/Contamination/all_contaminated",
            ".amb",
            ".ann",
            ".bwt",
            ".pac",
            ".sa")
    conda:
         "env/genomics.yaml"
    shell:
        'bwa index {input}'

rule bwa:
    input:
         contamination="resources/Contamination/all_contaminated.fasta",
         raw_reads="resources/RawData/DNA/raw/{DNAseq}.fastq.gz"
    params:
          threads=32
    output:
          #raw_reads_unmapped="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.clean.bam",
          #raw_reads_unmapped_sorted="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.clean.sorted.bam",
          #raw_reads_unmapped_fastq="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.clean.fastq"
          raw_reads_unmapped="resources/RawData/DNA/clean/{DNAseq}.clean.bam",
          raw_reads_unmapped_sorted="resources/RawData/DNA/clean/{DNAseq}.clean.sorted.bam",
          raw_reads_unmapped_fastq="resources/RawData/DNA/clean/{DNAseq}.clean.fastq.gz"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ContaminationRemovalRawReads.py"
          """

rule bowtie2_index_cleaning_contamination:
    input:
        "resources/Contamination/all_contaminated.fasta"
    output:
        multiext(
            "resources/Contamination/all_contaminated",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2")
    params:
        outname="resources/Contamination/all_contaminated",
        num_threads=32
    conda:
        "env/genomics.yaml"
    shell:
        'bowtie2-build {input} --threads {params.num_threads} {params.outname}'

rule bowtie2_paired_reads_cleaning_contamination:
    input:
        contamination="resources/Contamination/all_contaminated.fasta",
        ill_R1="resources/RawData/DNA/raw/{sample}_R1.fastq.gz",
        ill_R2="resources/RawData/DNA/raw/{sample}_R2.fastq.gz",
    output:
        clean_ill_R1="resources/RawData/DNA/clean/short/{sample}_R1.fastq.gz",
        clean_ill_R2="resources/RawData/DNA/clean/short/{sample}_R2.fastq.gz",
        contaminated_short= "resources/RawData/DNA/clean/short/contamination/{sample}.bam"
    params:
        threads=32,
        paired= True
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ContaminationRemovalRawReads.py"

rule bowtie2_single_reads_cleaning_contamination:
    input:
        contamination="resources/Contamination/all_contaminated.fasta",
        long_reads="resources/RawData/DNA/raw/{sample}.fastq.gz",
    output:
        clean_long="resources/RawData/DNA/clean/long/{sample}.fastq.gz",
        contaminated_long= "resources/RawData/DNA/clean/long/contamination/{sample}.bam"
    params:
        threads=32,
        paired= False
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ContaminationRemovalRawReads.py"

#Assembly
rule flye:
    input:
         reads="resources/RawData/DNA/clean/long/nanopore.fastq.gz",
    params:
          genome_size="114m",
          threads=25,
    output:
          assembly="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/flye/flye_{genome}.fasta",
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/FlyeAssembler.py"

rule masurca:
    input:
         config="resources/AssemblyConfig/assemble.sh"
    params:
          path="resources/RawData/DNA/clean/short/",
    output:
          "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/masurca/masurca_{genome}.fasta"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/MasurcaAssembler.py"

rule polca:
    input:
         assembly="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_{genome}.fasta",
         illumina_run1_R1="resources/RawData/DNA/clean/short/illumina_run1_R1.fastq.gz",
         illumina_run1_R2="resources/RawData/DNA/clean/short/illumina_run1_R2.fastq.gz",
         illumina_run2_R1="resources/RawData/DNA/clean/short/illumina_run2_R1.fastq.gz",
         illumina_run2_R2="resources/RawData/DNA/clean/short/illumina_run2_R2.fastq.gz",
         illumina_run3_R1="resources/RawData/DNA/clean/short/illumina_run3_R1.fastq.gz",
         illumina_run3_R2="resources/RawData/DNA/clean/short/illumina_run3_R2.fastq.gz",
    output:
          polished_assembly="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}_polished_{genome}.fasta"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/Polishing.py"

#Evaluation
rule quast:
    input:
         assembly="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}_polished_{genome}.fasta",
    params:
          threads=2
    output:
          report_dir=directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/quast_report/")
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/AssemblyQualityCheck.py"


rule bowtie2_biult_index_evaluation:
    input:
         "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta"
    output:
          multiext(
              "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembler}/{assembler}_polished_{genome}",
              ".1.bt2",
              ".2.bt2",
              ".3.bt2",
              ".4.bt2",
              ".rev.1.bt2",
              ".rev.2.bt2")
    params:
          outname="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembler}/{assembler}_polished_{genome}.fasta",
          num_threads=30
    conda:
         "env/genomics.yaml"
    shell:
         'bowtie2-build {input} --threads {params.num_threads} {params.outname}'

rule bowtie2_evaluation:
    input:
         index=multiext(
             "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembler}/{assembler}_polished_{genome}",
             ".1.bt2",
             ".2.bt2",
             ".3.bt2",
             ".4.bt2",
             ".rev.1.bt2",
             ".rev.2.bt2"),
            ill_R1="resources/RawData/DNA/clean/short/{sample}_R1.fastq.gz",
            ill_R2="resources/RawData/DNA/clean/short/{sample}_R2.fastq.gz"
    output:
          bam="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{assembler}_polished_{genome}/{sample}.bam",
          bai="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{assembler}_polished_{genome}/{sample}.bai"
    params:
          threads=32,
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/MapShortReadsToAssembly.py"

rule meryl:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta",
    output:
          merylDB=directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/merlyDB"),
          repetitive_k15="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/repetitive_k15.txt",
    params:
          num_threads=30,
          nanopore=True
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/CalculateKmerLongReads.py"

rule winnowmap:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta",
         long_read="resources/RawData/DNA/clean/long/{long_read}.fastq.gz",
         merylDB="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/merlyDB",
         repetitive_k15="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/repetitive_k15.txt",
    output:
          bam="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/{long_read}.bam",
          bai="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/{long_read}.bai"
    params:
          num_threads=32,
          nanopore=True
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/MapLongReadsToAssembly.py"

#Genome Annotation Workflow
#Structural Annotation
rule prodigal:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta",
    output:
          gff="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/prodigal/{genome}.gff",
          faa="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/prodigal/{genome}.faa",
          ffn="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/prodigal/{genome}.ffn"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/ProdigalAnnotation.py"
rule train_glimmer_hmm:
    input:
         training_genes="resources/Train_GlimmerHMM/training_genes.fasta",
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta"
    params:
          n=150,
          v=50
    output:
          trained_genes="output/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/glimmerhmm/{genome}_trained_genes.hmm",
          gff="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/glimmerhmm/{genome}.gff",
          faa="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/glimmerhmm/{genome}.faa",
          ffn="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/glimmerhmm/{genome}.ffn"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/GlimmerHMMAnnotation.py"
"""rule glimmerhmm:
    input:
        genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{genome}.fasta",
    output:
        gff="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{genome}.gff",
        faa="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{genome}.faa",
        ffn="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{genome}.ffn"
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/GlimmerHMMAnnotation.py"""

#Functional Annotation
rule diamond_blastp:
    input:
         genome="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{annotation}/{genome}.faa"
    output:
          "output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/{genome}_diplomonads.blastp"
    params:
          db_prefix="path/to/database_prefix",
          outfmt=6,
          threads=32,
          max_target_seqs=500,
          max_hsps=1,
          more_sensitive="",
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/Diamond.py"
rule eggnogmapper:
    input:
         proteome="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{annotation}/{genome}.faa"
    output:
          "output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/{genome}_eggnogmapper_results.tsv"
    params:
          threads=32,
          diamond="diamond",
          outdir="output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/",
          datadir="path/to/data",

    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/Eggnogmapper.py"
rule interproscan:
    input:
         proteome="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{annotation}/{genome}.faa"
    output:
          "output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/{genome}_diplomonads_interproscan_results.tsv"
    params:
          threads=32,
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/Interproscan.py"

"""
Comparative Genomics Analysis
    1: Genome Structure Level
        -Repeat Analysis
        -RNA annotation
    2: Sequence Similarity Level
        -Orthologous Clusters
        -COG Clusters
        -Superfamily Clusters
    3: Protein Domain Level
        -Pfam domains
        -Domain schematics
        -Domian length distribution

"""

#Genome Structure Level
rule build_database:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta",
    output:
          multiext("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_RModeler/{genome}_db",
                   ".nhr",
                   ".nnd",
                   ".nin",
                   ".nni",
                   ".nog",
                   ".nsq",
                   ".translation")
    params:
          db_name="output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_RModeler/{genome}_db"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/builddatabase.py"

rule repeatmodeler:
    input:
         db="output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_RModeler/{genome}_db.nhr"
    output:
          "output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_RModeler/{genome}_db-families.fasta"
    params:
          db_name="output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_RModeler/{genome}_db",
          threads = 8,
          engine="ncbi"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/Repeatmodeler.py"

rule repeatmasker:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta",
         lib="output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_RModeler/{genome}_db-families.fasta"
    output:
          directory("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_RMasker")
    conda:
         "env/genomics.yaml"
    threads: 32
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/Repeatmasker.py"

rule tRNAscan:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta"
    params: threads=8
    output:
          tRNA="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{genome}.tRNAscan",
          stats="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{genome}.stats",
          gff="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{genome}.gff"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/tRNAscan.py"

rule tRNAscan_cov:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta"
    params: threads=8
    output:
          tRNA="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/sensitive_search/{genome}.tRNAscan_cov",
          stats="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/sensitive_search/{genome}.stats_cov"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/tRNAscan_cov.py"

rule barrnap:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta"
    output:
          gff="output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}.rrna.gff",
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/barrnap.py"

rule cdhit:
    input:
        genome = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembler}_polished_{genome}.fasta"
    params:
        threads=8
    output: "output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/{genome}_{n}.cdhit"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/cdhit.py"

rule orthofinder:
    input:
         proteome="resources/Orthofinder/sp/"
    output:
        directory('output/ComparativeGenomics/2_SequenceSimilarityLevel/')
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/2_SequenceSimilarityLevel/Orthofinder.py"

rule orthofinder_rerun:
    input:
         new_sp="resources/Orthofinder/new_sp",
         old_sp="output/Genomics/3_ComparativeGenomicsAnalysis/2_SequenceSimilarityLevel/{assembler}/{annotation}/OrthoFinder/{results}/WorkingDirectory/"
    output:
          directory('output/Genomics/3_ComparativeGenomicsAnalysis/2_SequenceSimilarityLevel/{assembler}/{annotation}/{results}/new_sp')
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/2_SequenceSimilarityLevel/Orthofinder_rerun.py"



rule cog_barplot:

# species-specific and conserved OG
# barplot
# extract csv

rule superfamily_heatmap:

# Superfamily IPR
# heatmap
# extract csv

rule domain_schematic:

# Pfam domain IPR
# schematic
# extract csv

rule domain_length_distribution:
# Superfamily & Pfam IPR
# length distribution
# extract stats
