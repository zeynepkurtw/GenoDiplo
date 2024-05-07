configfile: "env/config.yaml"

rule all:
    input:
         #fastqc
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.fastq.gz.html",
                read = config["DNAseq"]),
        #trimmomatic
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}_R1.unique.trimmed.fastq",
               read=["illumina_run1", "illumina_run2", "illumina_run3"]),
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
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/flye.assembly.fasta",
         #masurca
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/masurca.assembly.fasta",
         #polca
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembly}.polished.fasta",
               assembly=["flye", "masurca"]),
        #quast
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembly}.quast_report",
               assembly=["flye", "masurca"]),
        #bowtie2_paired_reads
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/{process}/{reads}.pair.bam",
                assembly=["flye", "masurca"],
                process=["raw", "clean"],
                reads=["illumina_run1", "illumina_run2", "illumina_run3"]),

        #bowtie2_single_reads
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/{process}/{reads}.sin.bam",
                assembly=["flye", "masurca"],
                process=["raw", "clean"],
                reads=["illumina_run1", "illumina_run2", "illumina_run3"]),
         #meryl
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/winnowmap/merlyDB",
                assembly=["flye", "masurca"]),
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/winnowmap/repetitive_k15.txt",
                assembly=["flye", "masurca"]),
         #winnowmap
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/{process}/winnowmap/{reads}.win.bam",
                assembly=["flye", "masurca"],
                process=["raw", "clean"],
                reads=config["nanopore"])


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
          r1_u="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}_R1.unique.trimmed.fastq",
          r2_u="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}_R2.unique.trimmed.fastq",
          r1_d="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}_R1.duplicate.trimmed.fastq",
          r2_d="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}_R2.duplicate.trimmed.fastq"

    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/TrimIlluminaReads.py"
rule fastqc:
    input:
        r1="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.unique.trimmed.fastq",
        r2="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.duplicate.trimmed.fastq",
    output:
        html="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{read}.unique.trimmed_fastqc.html",
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ReadQualityCheck.py"
#rule calculatereadmeanstdev
rule bwa:
    input:
        contamination="resources/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/contamination.fasta",
        raw_reads="resources/RawData/DNA/{read}.fastq.gz"
    output:
        raw_reads_unmapped="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.clean.bam",
        raw_reads_unmapped_sorted="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.clean.sorted.bam",
        raw_reads_unmapped_fastq="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.clean.fastq"
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ContaminationRemovalRawReads.py"
rule flye:
    input:
        reads= "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.clean.fastq",
    params:
        genome_size= "114m",
        threads = 25,
    output:
        assembly= "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{read}.flye.assembly.fasta",
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/FlyeAssembler.py"
rule masurca:
    input:
        config = "resources/AssemblyConfig/masurca_config.sh"
    output:
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/masurca.assembly.fasta"
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/MasurcaAssembler.py"
rule polca:
    input:
        assembly = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembly}.assembly.fasta",
        illumina_run1_R1= "resources/RawData/DNA/illumina_run1_R1.fastq.gz",
        illumina_run1_R2= "resources/RawData/DNA/illumina_run1_R2.fastq.gz",
        illumina_run2_R1= "resources/RawData/DNA/illumina_run2_R1.fastq.gz",
        illumina_run2_R2= "resources/RawData/DNA/illumina_run2_R2.fastq.gz",
        illumina_run3_R1= "resources/RawData/DNA/illumina_run3_R1.fastq.gz",
        illumina_run3_R2= "resources/RawData/DNA/illumina_run3_R2.fastq.gz",
    output:
        polished_assembly = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembly}.polished.fasta"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/Polishing.py"
rule quast:
    input:
        assembly = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembly}.assembly.fasta",
    params:
        threads = 2
    output:
        quast_report = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembly}.quast_report"
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/AssemblyQualityCheck.py"
#Assembly coverage depth
rule bowtie2_biult_index:
    input:
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembly}.assembly.fasta"
    output:
        multiext(
            "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembly}",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2")
    params:
        outname = "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembly}",
        num_threads = 30
    conda:
        "env/genomics.yaml"
    shell:
        'bowtie2-build {input} --threads {params.num_threads} {params.outname}'
rule bowtie2_paired_reads:
    input:
        index=multiext(
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembly}",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2"),
        illumina_R1 ="resources/RawData/DNA/{process}/{reads}_R1.fastq.gz",
        illumina_R2 ="resources/RawData/DNA/{process}/{reads}_R2.fastq.gz"
    output:
        bam= "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/{process}/{reads}.pair.bam",
        bai= "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/{process}/{reads}.pair.bai"
    params:
        paired = True,
        num_threads = 30,
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/MapShortReadsToAssembly.py"
rule bowtie2_single_reads:
    input:
        index=multiext(
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembly}",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2"),
        read="resources/RawData/DNA/{process}/{reads}.fastq.gz",
    output:
        bam= "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/{process}/{reads}.sin.bam",
        bai= "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/{process}/{reads}.sin.bai"
    params:
        num_threads = 30,
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/MapShortReadsToAssembly.py"
rule meryl:
    input:
        genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}.assembly.fasta",
    output:
        merylDB= directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/winnowmap/merlyDB"),
        repetitive_k15="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/winnowmap/repetitive_k15.txt",
    params:
        num_threads = 30,
        nanopore=True
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/CalculateKmerLongReads.py"
rule winnowmap:
    input:
        genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}.assembly.fasta",
        read="resources/RawData/DNA/{process}/{reads}_R1.fastq.gz",
        merylDB="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/winnowmap/merlyDB",
        repetitive_k15="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/winnowmap/repetitive_k15.txt",
    output:
        bam="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/{process}/winnowmap/{reads}.win.bam",
        bai="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembly}/{process}/winnowmap/{reads}.win.bai"
    params:
        num_threads = 30,
        nanopore = True
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/MapLongReadsToAssembly.py"


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
