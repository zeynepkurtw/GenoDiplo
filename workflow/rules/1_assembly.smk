rule fastqc_before_trimming:
    input:
        input_dir = "/data/zeynep/HIN_data/DNA/raw",
    params:
        threads=32,
    output:
        out_dir = directory("results/Genomics/1_Assembly/1_ReadsPreprocessing/fastqc_before_trimming/"),
    conda:
         "envs/genomics.yaml",
    script:
         "scripts/Genomics/1_Assembly/1_ReadsPreprocessing/ReadQualityCheck.py"

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
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/1_ReadsPreprocessing/TrimIlluminaReads.py"

rule fastqc_after_trimming:
    input:
         input_dir="/data/zeynep/HIN_data/DNA/trimmed"
    params:
        threads=32,
    output:
          out_dir=directory("results/Genomics/1_Assembly/1_ReadsPreprocessing/fastqc_after_trimming/"),
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/1_ReadsPreprocessing/ReadQualityCheck.py"

#rule calculatereadmeanstdev

rule bwa_index_contamination:
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
         "envs/genomics.yaml"
    shell:
        'bwa index {input}'

rule bwa_cleaning_contamination:
    input:
         contamination="resources/Contamination/all_contaminated.fasta",
         raw_reads="/data/zeynep/HIN_data/DNA/raw/{reads}.fastq.gz"
    params:
          threads=32,
          paired=False
    output:
          raw_reads_unmapped="/data/zeynep/HIN_data/DNA/clean/cont/{reads}.bam",
          raw_reads_unmapped_sorted="/data/zeynep/HIN_data/DNA/clean/cont/{reads}.sorted.bam",
          raw_reads_unmapped_fastq="/data/zeynep/HIN_data/DNA/clean/{reads}.fastq.gz"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/1_ReadsPreprocessing/ContaminationRemovalRawReadsBWA.py"

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
        "envs/genomics.yaml"
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
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/1_ReadsPreprocessing/ContaminationRemovalRawReads.py"

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
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/1_ReadsPreprocessing/ContaminationRemovalRawReads.py"
"""
#Assembly
rule flye:
    input:
        reads="/data/zeynep/HIN_data/DNA/clean/nanopore.fastq.gz",
    params:
      genome_size="114m",
      threads=32,
    output:
          out_dir=directory("results/Genomics/1_Assembly/2_Assembly/flye/"),
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/2_Assemblers/FlyeAssembler.py"

rule masurca:
    input:
         config="resources/AssemblyConfig/config.txt"
    params:
          path="results/Genomics/1_Assembly/2_Assembly/masurca/",
    output:
          out_dir=directory("results/Genomics/1_Assembly/2_Assembly/masurca/")
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/2_Assemblers/MasurcaAssembler.py"

rule bwa_index_evaluation:
    input:
        "results/Genomics/1_Assembly/2_Assembly/{assembler}/assembly.fasta"
    output:
        multiext(
            "results/Genomics/1_Assembly/3_Evaluation/{assembler}/bwa/bwa_index/assembly",
            ".amb",
            ".ann",
            ".bwt",
            ".pac",
            ".sa")
    params:
        outname = "results/Genomics/1_Assembly/3_Evaluation/{assembler}/bwa/bwa_index/assembly",
        num_threads = 32
    conda:
         "envs/genomics.yaml"
    shell:
        'bwa index {input}'

rule bwa_evaluation_paired:
    input:
         index=multiext("results/Genomics/1_Assembly/3_Evaluation/{assembler}/bwa/bwa_index/assembly",
            ".amb",
            ".ann",
            ".bwt",
            ".pac",
            ".sa"),
         ill_R1="/data/zeynep/HIN_data/DNA/clean/{sample}_R1.fastq.gz",
         ill_R2="/data/zeynep/HIN_data/DNA/clean/{sample}_R1.fastq.gz"
    params:
          threads=32,
          paired=True
    output:
        bam = "results/Genomics/1_Assembly/3_Evaluation/{assembler}/bwa/paired/{sample}.bam",
        bai = "results/Genomics/1_Assembly/3_Evaluation/{assembler}/bwa/paired/{sample}.bai"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/1_ReadsPreprocessing/MapShortReadsToAssembly.py"

rule bwa_evaluation_single:
    input:
         index=multiext("results/Genomics/1_Assembly/3_Evaluation/{assembler}/bwa/bwa_index/assembly",
                        ".amb",
                        ".ann",
                        ".bwt",
                        ".pac",
                        ".sa"),
         single="/data/zeynep/HIN_data/DNA/clean/{sample}.fastq.gz",
    params:
          threads=32,
          paired=False
    output:
        bam = "results/Genomics/1_Assembly/3_Evaluation/{assembler}/bwa/single/{sample}.bam",
        bai = "results/Genomics/1_Assembly/3_Evaluation/{assembler}/bwa/single/{sample}.bai"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/1_ReadsPreprocessing/MapShortReadsToAssembly.py"

rule meryl:
    input:
         genome="results/Genomics/1_Assembly/2_Assembly/{assembler}/assembly.fasta",
    output:
          merylDB=directory("results/Genomics/1_Assembly/3_Evaluation/{assembler}/winnowmap/merlyDB"),
          repetitive_k15="results/Genomics/1_Assembly/3_Evaluation/{assembler}/winnowmap/repetitive_k15.txt",
    params:
          num_threads=30,
          nanopore=True
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/CalculateKmerLongReads.py"

rule winnowmap:
    input:
         genome="results/Genomics/1_Assembly/2_Assembly/{assembler}/assembly.fasta",
         long_read="/data/zeynep/HIN_data/DNA/clean/{long_read}.fastq.gz",
         merylDB="results/Genomics/1_Assembly/3_Evaluation/{assembler}/winnowmap/merlyDB",
         repetitive_k15="results/Genomics/1_Assembly/3_Evaluation/{assembler}/winnowmap/repetitive_k15.txt",
    output:
          bam="results/Genomics/1_Assembly/3_Evaluation/{assembler}/winnowmap/{long_read}.bam",
          bai="results/Genomics/1_Assembly/3_Evaluation/{assembler}/winnowmap/{long_read}.bai"
    params:
          num_threads=32,
          nanopore=True
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/MapLongReadsToAssembly.py"

rule pilon:
    input:
        assembly="results/Genomics/1_Assembly/2_Assembly/{assembler}/assembly.fasta",
        illumina_run1="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/illumina_run1_R2_single.bam",
        illumina_run2="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/illumina_run2_paired.bam",
        illumina_run3="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/illumina_run3_paired.bam"
    params:
        threads=32
    output:
        polished_assembly="results/Genomics/1_Assembly/2_Assembly/pilon/{assembler}/assembly_polished.fasta"
    conda:
         "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/2_Assemblers/Polishing.py"

#Evaluation
rule quast:
    input:
         assembly="results/Genomics/1_Assembly/2_Assembly/pilon/{assembler}/assembly_polished.fasta",
    params:
          threads=32
    output:
          report_dir=directory("results/Genomics/1_Assembly/3_Evaluation/quast/{assembler}/")
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/AssemblyQualityCheck.py"
