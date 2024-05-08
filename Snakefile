configfile: "env/config.yaml"

rule all:
    input:
        #fastqc
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{seq}.raw_fastqc.html",
                seq=config["reads"]),
        #trimmomatic
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{run}_R1.unique.trimmed.fastq",
               run=["illumina_run1", "illumina_run2", "illumina_run3"]),
        #fastqc
        #expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{run}_R{pair}.{type}.trimmed_fastqc.html",
         #      run=["illumina_run1", "illumina_run2", "illumina_run3"],
          #     pair=[1, 2],
           #    type = ["unique", "duplicate"]),
        #calculatereadmeanstdev
        #ContaminationDetection.py
        #bwa
         expand("resources/RawData/DNA/{process}/{DNAseq}.clean.fastq.gz",
                DNAseq=config["reads"],
                process=["clean"]),
        #flye
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/flye/{genome}.fasta",
               genome=["Hexamita"]),
        #masurca
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/masurca/{genome}.fasta",
            genome=["Hexamita"]),
        #polca
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/polca/{process}/{genome}.polished.fasta",
               assembler=["flye", "masurca"],
               process=["clean"],
               genome=["Hexamita"]),
        #quast
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/quast_report/",
               assembler=["flye", "masurca"],
               genome=["Hexamita"]),
        #bowtie2_paired_reads
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/{process}/{run}.pair.bam",
                assembler=["flye", "masurca"],
                genome=["Hexamita"],
                process=["clean"],
                run=["illumina_run1", "illumina_run2", "illumina_run3"]),

        #bowtie2_single_reads
       # expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/{process}/{run}.sin.bam",
        #        assembler=["flye", "masurca"],
         #       genome=["Hexamita"],
          #      process=["clean"],
             #   run=["illumina_run1", "illumina_run2", "illumina_run3"]),
        #meryl
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/merlyDB",
                assembler=["flye", "masurca"],
                genome=["Hexamita"]),
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/repetitive_k15.txt",
                assembler=["flye", "masurca"],
                genome=["Hexamita"]),
        #winnowmap
        expand("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/{process}/winnowmap/{long_reads}.win.bam",
                assembler=["flye", "masurca"],
                genome=["Hexamita"],
                process=["clean"],
                long_reads=config["nanopore"])


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

rule fastqc_before_trimming:
    input:
         reads="resources/RawData/DNA/raw/{seq}.fastq.gz",
         outdir = "output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing"
    output:
        html="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{seq}.raw_fastqc.html",
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ReadQualityCheck.py"
rule trimmomatic:
    input:
        r1="resources/RawData/DNA/raw/{run}_R1.fastq.gz",
        r2="resources/RawData/DNA/raw/{run}_R2.fastq.gz"
    output:
          r1_u="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{run}_R1.unique.trimmed.fastq",
          r2_u="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{run}_R2.unique.trimmed.fastq",
          r1_d="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{run}_R1.duplicate.trimmed.fastq",
          r2_d="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{run}_R2.duplicate.trimmed.fastq"
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/TrimIlluminaReads.py"
rule fastqc_after_trimming:
    input:
        r1="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{seq}.unique.trimmed.fastq",
        r2="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{seq}.duplicate.trimmed.fastq",
        outdir= "output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing"
    output:
        html="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/{seq}.unique.trimmed_fastqc.html",
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/ReadQualityCheck2.py"
#rule calculatereadmeanstdev
rule bwa:
    input:
        contamination="output/Genomics/1_HybridGenomeAssemblyWorkflow/1_ReadsPreprocessing/contamination.fasta",
        raw_reads="resources/RawData/DNA/raw/{DNAseq}.fastq.gz"
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
rule flye:
    input:
        reads= "resources/RawData/DNA/clean/nanopore.clean.fastq.gz",
    params:
        genome_size= "114m",
        threads = 25,
    output:
        assembly= "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/flye/{genome}.fasta",
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/FlyeAssembler.py"
rule masurca:
    input:
        config = "resources/AssemblyConfig/masurca_config.sh"
    output:
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/masurca/{genome}.fasta"
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/MasurcaAssembler.py"
rule polca:
    input:
        assembly = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{genome}.fasta",
        illumina_run1_R1= "resources/RawData/DNA/{process}/illumina_run1_R1.fastq.gz",
        illumina_run1_R2= "resources/RawData/DNA/{process}/illumina_run1_R2.fastq.gz",
        illumina_run2_R1= "resources/RawData/DNA/{process}/illumina_run2_R1.fastq.gz",
        illumina_run2_R2= "resources/RawData/DNA/{process}/illumina_run2_R2.fastq.gz",
        illumina_run3_R1= "resources/RawData/DNA/{process}/illumina_run3_R1.fastq.gz",
        illumina_run3_R2= "resources/RawData/DNA/{process}illumina_run3_R2.fastq.gz",
    output:
        polished_assembly = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/polca/{process}/{genome}.polished.fasta"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assemblers/Polishing.py"
rule quast:
    input:
        assembly = "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/polca/{genome}.polished.fasta",
    params:
        threads = 2
    output:
        report_dir=directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/quast_report/")
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/AssemblyQualityCheck.py"
#Assembly coverage depth
rule bowtie2_biult_index:
    input:
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{assembly}.assembly.fasta"
    output:
        multiext(
            "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembler}/{assembly}",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2")
    params:
        outname = "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembler}/{assembly}",
        num_threads = 30
    conda:
        "env/genomics.yaml"
    shell:
        'bowtie2-build {input} --threads {params.num_threads} {params.outname}'
rule bowtie2_paired_reads:
    input:
        index=multiext(
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembler}/{assembly}",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2"),
        illumina_R1 ="resources/RawData/DNA/clean/{run}_R1.clean.fastq.gz",
        illumina_R2 ="resources/RawData/DNA/clean/{run}_R2.clean.fastq.gz"
    output:
        bam= "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{assembly}/{process}/{run}.pair.bam",
        bai= "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{assembly}/{process}/{run}.pair.bai"
    params:
        paired = True,
        num_threads = 30,
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/MapShortReadsToAssembly.py"
"""rule bowtie2_single_reads:
    input:
        index=multiext(
        "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/index_bt2/{assembler}/{assembly}",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2"),
        run="resources/RawData/DNA/clean/illumina_run1_R1.clean.fastq.gz",
    output:
        bam= "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{assembly}/{process}/{run}.sin.bam",
        bai= "output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{assembly}/{process}/{run}.sin.bai"
    params:
        num_threads = 30,
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/MapShortReadsToAssembly.py"""

rule meryl:
    input:
        genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{genome}.assembly.fasta",
    output:
        merylDB= directory("output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/merlyDB"),
        repetitive_k15="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/repetitive_k15.txt",
    params:
        num_threads = 30,
        nanopore=True
    conda:
        "env/genomics.yaml"
    script:
        "scripts/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/CalculateKmerLongReads.py"
rule winnowmap:
    input:
        genome="output/Genomics/1_HybridGenomeAssemblyWorkflow/2_Assembly/{assembler}/{genome}.fasta",
        long_read="resources/RawData/DNA/{process}/{long_read}.clean.fastq.gz",
        merylDB="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/merlyDB",
        repetitive_k15="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/winnowmap/repetitive_k15.txt",
    output:
        bam="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/{process}/winnowmap/{long_read}.win.bam",
        bai="output/Genomics/1_HybridGenomeAssemblyWorkflow/3_AssemblyEvaluation/{assembler}/{genome}/{process}/winnowmap/{long_read}.win.bai"
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
