configfile: "env/config.yaml"
rule all:
    input:
       #fastqc_before_trimming,
         "output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/fastqc_before_trimming",
         #trimmomatic
         expand("/data/zeynep/HIN_data/DNA/trimmed/{run}_R1.unique.trimmed.fastq",
                run=["illumina_run1", "illumina_run2", "illumina_run3"]),
         #fastqc_after_trimming
            "output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/fastqc_after_trimming",
         #ContaminationDetection.py
         #bwa_cleaning_contamination
         expand("/data/zeynep/HIN_data/DNA/clean/{DNAseq}.fastq.gz",
                DNAseq=config["reads"]),
        ##flye
         "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/flye/",
         #masurca
          "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/masurca/",
         #bowtie2_paired_reads_evaluation
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/bowtie2/{sample}.bam",
                assembler=["flye", "masurca/flye.mr.83.17.15.0.02"],
                sample=["illumina_run1", "illumina_run2", "illumina_run3"]),
         #meryl_evaluation
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/winnowmap/merlyDB",
                assembler=["flye", "masurca/flye.mr.83.17.15.0.02"],
                genome=["Hexamita"]),
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/winnowmap/repetitive_k15.txt",
                assembler=["flye", "masurca/flye.mr.83.17.15.0.02"],
                genome=["Hexamita"]),
         #winnowmap_evaluation
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/winnowmap/{long_reads}.bam",
                assembler=["flye", "masurca/flye.mr.83.17.15.0.02"],
                long_reads=["nanopore", "pacbio"]),
         #pilon
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/{assembly}_polished.fasta",
                assembler=["flye", "masurca/flye.mr.83.17.15.0.02"],
                assembly=["assembly"]),
         #quast
         expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/quast/{assembly}/",
                assembler=["flye"],
                assembly=["assembly"]),
"""  #prodigal
         expand("output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/prodigal/genome.gff",
                assembler=["flye", "masurca"]),
         #glimmerhmm
         expand("output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/glimmerhmm/genome.faa",
                assembler=["flye", "masurca"]),
         #diamond_blastp
       #  expand("output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/genome_diplomonads.blastp",
        #        annotation=["glimmerhmm"],
         #       assembler=["flye", "masurca"]),
         #eggnogmapper
         expand("output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/eggnogmapper_results.tsv",
                annotation=["glimmerhmm"],
                assembler=["flye", "masurca"]),
         #interproscan
         expand("output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/interproscan_results.tsv",
                annotation=["glimmerhmm"],
                assembler=["flye", "masurca"]),
        #repeatmodeler
         expand("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db-families.fasta",
                assembler=["flye", "masurca"]),
        #repeatmasker
            expand("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RMasker",
                   assembler=["flye", "masurca"]),
        #tRNAscan
            expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/genome.tRNAscan",
                   assembler=["flye", "masurca"]),
        #tRNAscan_cov
            expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/sensitive_search/genome.tRNAscan_cov",
                   assembler=["flye", "masurca"]),
        #barrnap
            expand("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/genome.rrna.gff",
                   assembler=["flye", "masurca"]),
        #cdhit
            expand("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/genome_{n}.cdhit",
                   assembler=["flye", "masurca"],
                   n=[0.70, 0.75, 0.80, 0.85, 0.90, 0.95, 1]),
        #orthofinder
            #"output/ComparativeGenomics/2_SequenceSimilarityLevel/"
        #orthofinder_rerun


#expand("output/2_cdhit/{sp}_{n}.cdhit", n=config["seq_identity"], sp=config["species"])
#expand("output/7_tRNAscan/{sp}.tRNAscan",sp=["HIN", "muris", "wb", "spiro"]),
#expand("output/7_tRNAscan/sensitive_search/{sp}.cov.tRNAscan",sp=[ "muris", "wb", "spiro"]),


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
        input_dir = "/data/zeynep/HIN_data/DNA/raw",
    params:
        threads=32,
    output:
        out_dir = directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/fastqc_before_trimming/"),
    conda:
         "env/genomics.yaml",
    script:
         "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ReadQualityCheck.py"

rule trimmomatic:
    input:
         r1="/data/zeynep/HIN_data/DNA/raw/{run}_R1.fastq.gz",
         r2="/data/zeynep/HIN_data/DNA/raw/{run}_R2.fastq.gz"
    params:
            threads=32,
    output:
          r1_u="/data/zeynep/HIN_data/DNA/trimmed/{run}_R1.unique.trimmed.fastq",
          r2_u="/data/zeynep/HIN_data/DNA/trimmed/{run}_R2.unique.trimmed.fastq",
          r1_d="/data/zeynep/HIN_data/DNA/trimmed/{run}_R1.duplicate.trimmed.fastq",
          r2_d="/data/zeynep/HIN_data/DNA/trimmed/{run}_R2.duplicate.trimmed.fastq"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/TrimIlluminaReads.py"

rule fastqc_after_trimming:
    input:
         input_dir="/data/zeynep/HIN_data/DNA/trimmed"
    params:
        threads=32,
    output:
          out_dir=directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/fastqc_after_trimming/"),
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ReadQualityCheck.py"

#rule calculatereadmeanstdev

rule bwa_index:
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

rule bwa_cleaning_contamination:
    input:
         contamination="resources/Contamination/all_contaminated.fasta",
         raw_reads="/data/zeynep/HIN_data/DNA/raw/{DNAseq}.fastq.gz"
    params:
          threads=32,
          paired=False
    output:
          raw_reads_unmapped="/data/zeynep/HIN_data/DNA/clean/{DNAseq}.bam",
          raw_reads_unmapped_sorted="/data/zeynep/HIN_data/DNA/clean/{DNAseq}.sorted.bam",
          raw_reads_unmapped_fastq="/data/zeynep/HIN_data/DNA/clean/{DNAseq}.fastq.gz"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ContaminationRemovalRawReadsBWA.py"

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
        index=multiext(
             "resources/Contamination/all_contaminated",
             ".1.bt2",
             ".2.bt2",
             ".3.bt2",
             ".4.bt2",
             ".rev.1.bt2",
             ".rev.2.bt2"),
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
     index=multiext(
         "resources/Contamination/all_contaminated",
         ".1.bt2",
         ".2.bt2",
         ".3.bt2",
         ".4.bt2",
         ".rev.1.bt2",
         ".rev.2.bt2"),
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
"""
#Assembly
rule flye:
    input:
        reads="/data/zeynep/HIN_data/DNA/clean/nanopore.fastq.gz",
    params:
      genome_size="114m",
      threads=32,
    output:
          out_dir=directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/flye/"),
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/FlyeAssembler.py"

rule masurca:
    input:
         config="resources/AssemblyConfig/config.txt"
    params:
          path="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/masurca/",
    output:
          out_dir=directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/masurca/")
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/MasurcaAssembler.py"

rule bowtie2_biult_index_evaluation:
    input:
         "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/assembly.fasta"
    output:
          multiext(
              "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/bowtie2/index_bt2/assembly",
              ".1.bt2",
              ".2.bt2",
              ".3.bt2",
              ".4.bt2",
              ".rev.1.bt2",
              ".rev.2.bt2")
    params:
          outname="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/bowtie2/index_bt2/assembly",
          num_threads=30
    conda:
         "env/genomics.yaml"
    shell:
         'bowtie2-build {input} --threads {params.num_threads} {params.outname}'

rule bowtie2_evaluation:
    input:
         index=multiext(
             "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/bowtie2/index_bt2/assembly",
             ".1.bt2",
             ".2.bt2",
             ".3.bt2",
             ".4.bt2",
             ".rev.1.bt2",
             ".rev.2.bt2"),
            ill_R1="/data/zeynep/HIN_data/DNA/clean/{sample}_R1.fastq.gz",
            ill_R2="/data/zeynep/HIN_data/DNA/clean/{sample}_R2.fastq.gz"
    output:
          bam="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/bowtie2/{sample}.bam",
          bai="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/bowtie2/{sample}.bai"
    params:
          threads=32,
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/MapShortReadsToAssembly.py"

rule meryl:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/assembly.fasta",
    output:
          merylDB=directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/winnowmap/merlyDB"),
          repetitive_k15="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/winnowmap/repetitive_k15.txt",
    params:
          num_threads=30,
          nanopore=True
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/CalculateKmerLongReads.py"

rule winnowmap:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/assembly.fasta",
         long_read="/data/zeynep/HIN_data/DNA/clean/{long_read}.fastq.gz",
         merylDB="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/winnowmap/merlyDB",
         repetitive_k15="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/winnowmap/repetitive_k15.txt",
    output:
          bam="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/winnowmap/{long_read}.bam",
          bai="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/winnowmap/{long_read}.bai"
    params:
          num_threads=32,
          nanopore=True
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/MapLongReadsToAssembly.py"

rule pilon:
    input:
        assembly="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/assembly.fasta",
        illumina_run1="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/bowtie2/illumina_run1.bam",
        illumina_run2="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/bowtie2/illumina_run2.bam",
        illumina_run3="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/bowtie2/illumina_run3.bam"
    params:
        threads=32
    output:
        polished_assembly="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/assembly_polished.fasta"
    conda:
         "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/Polishing.py"

#Evaluation
rule quast:
    input:
         assembly="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/assembly_polished.fasta",
    params:
          threads=32
    output:
          report_dir=directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/quast/{assembler}/")
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/AssemblyQualityCheck.py"


#Genome Annotation Workflow
#Structural Annotation
rule prodigal:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/assembly_polished.fasta",
    output:
          gff="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/prodigal/{assembler}/genome.gff",
          faa="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/prodigal/{assembler}/genome.faa",
          ffn="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/prodigal/{assembler}/genome.ffn",
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/ProdigalAnnotation.py"
rule glimmerhmm:
    input:
        training_genes="resources/Train_GlimmerHMM/training_genes.fasta",
        genome= "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/assembly_polished.fasta",
    params:
          n=150,
          v=50
    output:
        trained_genes = "output/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/glimmerhmm/{assembler}/genome_trained_genes.hmm",
        gff="output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/genome.gff",
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/GlimmerHMMAnnotation.py"

#Functional Annotation
rule makeblastdb:
    input:
        "output/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{annotation}/genome.faa"
    output:
        multiext("output/Genomics/2_GenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{annotation}/genome",
            ".ndb",
            ".nhr",
            ".nin",
            ".not",
            ".nsq",
            ".ntf",
            ".nto")
    params:
        outname="output/{type}/db/{db}"
    conda:
        "envs/blast.yaml"
    shell:
        'makeblastdb -dbtype nucl -in {input} -out {params.outname}'

rule diamond_blastp:
    input:
         genome="output/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{annotation}/genome.faa"
    output:
          "output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/genome_diplomonads.blastp"
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
         proteome="output/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{annotation}/genome.faa"
    output:
          "output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/eggnogmapper_results.tsv"
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
         proteome="output/Genomics/2_DualGenomeAnnotationWorkflow/1_StructuralAnnotation/{assembler}/{annotation}/genome.faa"
    output:
          "output/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/{assembler}/{annotation}/interproscan_results.tsv"
    params:
          threads=32,
    conda:
         "env/genomics.yaml"
    script:
          "scripts/Genomics/2_DualGenomeAnnotationWorkflow/2_FunctionalAnnotation/Interproscan.py"


"""Comparative Genomics Analysis
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
rule build_database_repeatmodeler:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/assembly_polished.fasta",
    output:
          multiext("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db",
                   ".nhr",
                   ".nnd",
                   ".nin",
                   ".nni",
                   ".nog",
                   ".nsq",
                   ".translation")
    params:
          db_name="output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/builddatabase.py"

rule repeatmodeler:
    input:
         db="output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db.nhr"
    output:
          "output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db-families.fasta"
    params:
          db_name="output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db",
          threads = 8,
          engine="ncbi"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/Repeatmodeler.py"

rule repeatmasker:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/assembly_polished.fasta",
         lib="output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db-families.fasta"
    output:
          directory("output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RMasker")
    conda:
         "env/genomics.yaml"
    threads: 32
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/Repeatmasker.py"

rule tRNAscan:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/assembly_polished.fasta"
    params: threads=8
    output:
          tRNA="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/genome.tRNAscan",
          stats="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/genome.stats",
          gff="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/genome.gff"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/tRNAscan.py"

rule tRNAscan_cov:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/assembly_polished.fasta"
    params: threads=8
    output:
          tRNA="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/sensitive_search/genome.tRNAscan_cov",
          stats="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/sensitive_search/genome.stats_cov"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/tRNAscan_cov.py"

rule barrnap:
    input:
         genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/assembly_polished.fasta"
    output:
          gff="output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/genome.rrna.gff",
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/barrnap.py"

rule cdhit:
    input:
        genome = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/pilon/{assembler}/assembly_polished.fasta"
    params:
        threads=8
    output: "output/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/genome_{n}.cdhit"
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
