configfile: "env/config.yaml"

rule all:
    input:
         #fastqc
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.fastq.gz.html",
                read = config["DNAseq"]),
         #trimmomatic
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{run}_R{pair}.unique.trimmed.fastq",
                run=["illumina_run1", "illumina_run2", "illumina_run3"],
                pair=[1, 2]),
         #fastqc
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{run}_R{pair}.{type}.trimmed_fastqc.html",
               run=["illumina_run1", "illumina_run2", "illumina_run3"],
               pair=[1, 2],
               type = ["unique", "duplicate"]),
        #calculatereadmeanstdev
        #ContaminationDetection.py
        #bwa
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.unmapped.fastq",
               read=config["DNAseq"]),
        #flye
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.assembly.fasta",
               read=config["nanopore"]),

        #masurca

        #polca


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

rule trimmomatic:
    input:
        r1="resources/RawData/DNA/{read}.fastq.gz",
        r2="resources/RawData/DNA/{read}.fastq.gz"
    output:
        r1_u="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.unique.trimmed.fastq",
        r2_u="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.unique.trimmed.fastq",
        r1_d="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.duplicate.trimmed.fastq",
        r2_d="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.duplicate.trimmed.fastq"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/TrimIlluminaReads.py"

rule fastqc:
    input:
        r1="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.unique.trimmed.fastq",
        r2="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.duplicate.trimmed.fastq",
    output:
        html="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.unique.trimmed_fastqc.html",
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ReadQualityCheck.py"

#rule calculatereadmeanstdev

rule bwa:
    input:
        contamination= "resources/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/contamination.fasta",
        raw_reads= "resources/RawData/DNA/{read}.fastq.gz",
    output:
        raw_reads_unmapped= "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.clean.bam",
        raw_reads_unmapped_sorted= "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.clean.sorted.bam",
        raw_reads_unmapped_fastq= "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.clean.fastq",

 rule flye:
    input:
        reads= "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.clean.fastq",
    params:
        genome_size= "114m",
        threads = 25,
    output:
        assembly= "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.flye.assembly.fasta",
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/FlyeAssembler.py"

rule masurca:
    input:
        config = "resources/AssemblyConfig/masurca_config.sh"
    output:
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/assembled_genome.fasta"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/MasurcaAssembler.py"
rule polca:
    input:
        assembly = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembly}.fasta",
        illumina_run1_R1= "resources/RawData/DNA/illumina_run1_R1.fastq.gz",
        illumina_run1_R2= "resources/RawData/DNA/illumina_run1_R2.fastq.gz",
        illumina_run2_R1= "resources/RawData/DNA/illumina_run2_R1.fastq.gz",
        illumina_run2_R2= "resources/RawData/DNA/illumina_run2_R2.fastq.gz",
        illumina_run3_R1= "resources/RawData/DNA/illumina_run3_R1.fastq.gz",
        illumina_run3_R2= "resources/RawData/DNA/illumina_run3_R2.fastq.gz",
    output:
        polished_assembly = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.polished.fasta"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/Polishing.py"


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
