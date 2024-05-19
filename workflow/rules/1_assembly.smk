rule fastqc_before_trimming:
    input:
        input_dir = "/data/zeynep/HIN_data/DNA/raw",
    params:
        threads=32,
    output:
        out_dir = directory("results/Genomics/1_Assembly/1_Preprocessing/fastqc_before_trimming/"),
    conda:
         "envs/genomics.yaml",
    script:
         "scripts/Genomics/1_Assembly/1_Preprocessing/ReadQualityCheck.py"

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
          "scripts/Genomics/1_Assembly/1_Preprocessing/ContaminationRemovalRawReadsBWA.py"

rule trimmomatic:
    input:
         r1="/data/zeynep/HIN_data/DNA/clean/{sample}_R1.fastq.gz",
         r2="/data/zeynep/HIN_data/DNA/clean/{sample}_R2.fastq.gz"
    params:
            threads=32,
    output:
          r1_p="/data/zeynep/HIN_data/DNA/trimmed/paired/{sample}_R1.fastq",
          r1_up="/data/zeynep/HIN_data/DNA/trimmed/unpaired/{sample}_R1.fastq",
          r2_p="/data/zeynep/HIN_data/DNA/trimmed/paired/{sample}_R2.fastq",
          r2_up="/data/zeynep/HIN_data/DNA/trimmed/unpaired/{sample}_R2.fastq"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/1_Preprocessing/TrimIlluminaReads.py"

rule fastqc_after_trimming:
    input:
         input_dir="/data/zeynep/HIN_data/DNA/trimmed"
    params:
        threads=32,
    output:
          out_dir=directory("results/Genomics/1_Assembly/1_Preprocessing/fastqc_after_trimming/"),
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/1_Preprocessing/ReadQualityCheck.py"

#rule calculatereadmeanstdev
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
        "scripts/Genomics/1_Assembly/1_Preprocessing/ContaminationRemovalRawReads.py"

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
        "scripts/Genomics/1_Assembly/1_Preprocessing/ContaminationRemovalRawReads.py"
"""
#Assembly
rule flye:
    input:
        reads="/data/zeynep/HIN_data/DNA/{process}/nanopore.fastq.gz",
    params:
      genome_size="114m",
      threads=32,
    output:
          out_dir=directory("results/Genomics/1_Assembly/2_Assembly/flye/{process}/"),
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
          out_dir=directory("results/Genomics/1_Assembly/2_Assembly/masurca/flye.mr.33.17.15.0.02/")
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/2_Assemblers/MasurcaAssembler.py"

"""
neither bowtie2 nor bwa doesnt work on clenaed illumina reads 
file system latency error
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
          "scripts/Genomics/1_Assembly/1_Preprocessing/MapShortReadsToAssembly.py"

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
          "scripts/Genomics/1_Assembly/1_Preprocessing/MapShortReadsToAssembly.py"
"""
rule bowtie2_biult_index_evaluation:
    input:
         "results/Genomics/1_Assembly/2_Assembly/{assembler}/assembly.fasta"
    output:
          multiext(
              "results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/index_bt2/assembly",
              ".1.bt2",
              ".2.bt2",
              ".3.bt2",
              ".4.bt2",
              ".rev.1.bt2",
              ".rev.2.bt2")
    params:
          outname="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/index_bt2/assembly",
          threads=30
    conda:
         "envs/genomics.yaml"
    shell:
         'bowtie2-build {input} --threads {params.threads} {params.outname}'

rule bowtie2_evaluation_paired:
    input:
         index=multiext(
             "results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/index_bt2/assembly",
             ".1.bt2",
             ".2.bt2",
             ".3.bt2",
             ".4.bt2",
             ".rev.1.bt2",
             ".rev.2.bt2"),
            ill_R1="/data/zeynep/HIN_data/DNA/trimmed/paired/{sample}_R1.fastq",
            ill_R2="/data/zeynep/HIN_data/DNA/trimmed/paired/{sample}_R2.fastq"
    output:
          sorted_bam="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/paired/{sample}.bam",
    params:
          threads=32,
          paired= True
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/MapShortReadsToAssembly_bowtie2.py"

rule bowtie2_evaluation_single:
    input:
         index=multiext(
             "results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/index_bt2/assembly",
             ".1.bt2",
             ".2.bt2",
             ".3.bt2",
             ".4.bt2",
             ".rev.1.bt2",
             ".rev.2.bt2"),
         single="/data/zeynep/HIN_data/DNA/trimmed/unpaired/{read}.fastq",
    output:
          sorted_bam="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/unpaired/{read}.bam",
    params:
          threads=32,
          paired=False
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/MapShortReadsToAssembly_bowtie2.py"

rule meryl:
    input:
         genome="results/Genomics/1_Assembly/2_Assembly/{assembler}/assembly.fasta",
    output:
          merylDB=directory("results/Genomics/1_Assembly/3_Evaluation/{assembler}/winnowmap/merlyDB"),
          repetitive_k15="results/Genomics/1_Assembly/3_Evaluation/{assembler}/winnowmap/repetitive_k15.txt",
    params:
          threads=30,
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
          sorted_bam="results/Genomics/1_Assembly/3_Evaluation/{assembler}/winnowmap/{long_read}.bam",
          #bai="results/Genomics/1_Assembly/3_Evaluation/{assembler}/winnowmap/{long_read}.bai"
    params:
          threads=32,
          nanopore=True
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/MapLongReadsToAssembly.py"

rule pilon:
    input:
        assembly="results/Genomics/1_Assembly/2_Assembly/{assembler}/assembly.fasta",
        ill_run1="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/paired/illumina_run1.bam",
        ill_run2="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/paired/illumina_run2.bam",
        ill_run3="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/paired/illumina_run3.bam",
        ill_run1_R1_up="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/unpaired/illumina_run1_R1.bam",
        ill_run1_R2_up="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/unpaired/illumina_run1_R2.bam",
        ill_run2_R1_up="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/unpaired/illumina_run2_R1.bam",
        ill_run2_R2_up="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/unpaired/illumina_run2_R2.bam",
        ill_run3_R1_up="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/unpaired/illumina_run3_R1.bam",
        ill_run3_R2_up="results/Genomics/1_Assembly/3_Evaluation/{assembler}/bowtie2/unpaired/illumina_run3_R2.bam",

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
         assembly="results/Genomics/1_Assembly/2_Assembly/{assembler}/{process}/assembly.fasta",
    params:
          threads=32
    output:
          report_dir=directory("results/Genomics/1_Assembly/3_Evaluation/quast/{assembler}/{process}/")
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/AssemblyQualityCheck.py"

rule multiqc:
    input:
         input_dir="results/Genomics/1_Assembly/3_Evaluation/quast/,
    params:
          threads=32
    output:
          out_dir=directory("results/Genomics/1_Assembly/3_Evaluation/quast/multiqc/")
    conda:
         "envs/genomics.yaml"
    shell:
            'multiqc {input} -o {output}'