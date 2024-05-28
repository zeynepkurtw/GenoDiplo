rule fastqc_before_trimming:
    input:
         input_dir="/data/zeynep/HIN_data/DNA/raw",
    params:
          threads=32,
    output:
          out_dir=directory("results/Genomics/1_Assembly/1_Preprocessing/fastqc_before_trimming/"),
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

#Assembly
rule flye:
    input:
         reads="/data/zeynep/HIN_data/DNA/{process}/nanopore.fastq.gz",
    params:
          genome_size="114m",
          threads=32,
    output:
          out_dir=directory("results/Genomics/1_Assembly/2_Assemblers/flye/{process}/")
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/2_Assemblers/FlyeAssembler.py"

rule masurca:
    input:
         config="resources/AssemblyConfig/config.txt"
    params:
          path="results/Genomics/1_Assembly/2_Assemblers/masurca/"
    output:
          out_dir=directory("results/Genomics/1_Assembly/2_Assemblers/masurca/flye.mr.33.17.15.0.02/")
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/2_Assemblers/MasurcaAssembler.py"

rule seqkit:
    input:
        assembly="results/Genomics/1_Assembly/2_Assemblers/flye/raw/assembly.fasta"
    output:
        gc_stats = "results/Genomics/1_Assembly/2_Assemblers/flye/raw/filtered/gc_stats.txt",
        assembly_gc_filtered="results/Genomics/1_Assembly/2_Assemblers/flye/raw/filtered/assembly.fasta"
    params:
          min_gc=23,
          max_gc=43
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/3_Evaluation/ContaminationRemoval.py"

rule setup_nr_db:  #FIX how to actuvste this before running blastn
    output:
        outdir = protected(directory("/data/zeynep/databases"))
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/3_Evaluation/setup_nr_db.py"

rule blastn:
    input:
        query="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
        db="/data/zeynep/databases"
    output:
        "results/Genomics/1_Assembly/3_Evaluation/blastn/{assembler}/{db}/assembly.blastn"
    params:
        outfmt= "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen stitle",
        threads=32,
        evalue=1e-10,
        db_prefix="/data/zeynep/databases/{db}"
    conda:
        "envs/genomics.yaml"
    script:
        "scripts/Genomics/1_Assembly/3_Evaluation/blastn.py"


rule bowtie2_biult_index_evaluation:
    input:
         "results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta"
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
          sorted_bam="results/Genomics/1_Assembly/3_Evaluation/bowtie2/paired/{assembler}/{sample}.bam",
    params:
          threads=32,
          paired=True
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
          sorted_bam="results/Genomics/1_Assembly/3_Evaluation/bowtie2/unpaired/{assembler}/{read}.bam",
    params:
          threads=32,
          paired=False
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/MapShortReadsToAssembly_bowtie2.py"

rule meryl:
    input:
         genome="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
    output:
          merylDB=directory("results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/merlyDB"),
          repetitive_k15="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/repetitive_k15.txt",
    params:
          threads=30,
          nanopore=True
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/CalculateKmerLongReads.py"

rule winnowmap:
    input:
         genome="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
         long_read="/data/zeynep/HIN_data/DNA/clean/{long_read}.fastq.gz",
         merylDB="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/merlyDB",
         repetitive_k15="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/repetitive_k15.txt",
    output:
          sorted_bam="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/{long_read}.bam",
    #bai="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/{long_read}.bai"
    params:
          threads=32,
          nanopore=True
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/MapLongReadsToAssembly.py"

rule pilon:
    input:
         assembly="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
         ill_run1="results/Genomics/1_Assembly/3_Evaluation/bowtie2/paired/{assembler}/illumina_run1.bam",
         ill_run2="results/Genomics/1_Assembly/3_Evaluation/bowtie2/paired/{assembler}/illumina_run2.bam",
         ill_run3="results/Genomics/1_Assembly/3_Evaluation/bowtie2/paired/{assembler}/illumina_run3.bam",
         ill_run1_R1_up="results/Genomics/1_Assembly/3_Evaluation/bowtie2/unpaired/{assembler}/illumina_run1_R1.bam",
         ill_run1_R2_up="results/Genomics/1_Assembly/3_Evaluation/bowtie2/unpaired/{assembler}/illumina_run1_R2.bam",
         ill_run2_R1_up="results/Genomics/1_Assembly/3_Evaluation/bowtie2/unpaired/{assembler}/illumina_run2_R1.bam",
         ill_run2_R2_up="results/Genomics/1_Assembly/3_Evaluation/bowtie2/unpaired/{assembler}/illumina_run2_R2.bam",
         ill_run3_R1_up="results/Genomics/1_Assembly/3_Evaluation/bowtie2/unpaired/{assembler}/illumina_run3_R1.bam",
         ill_run3_R2_up="results/Genomics/1_Assembly/3_Evaluation/bowtie2/unpaired/{assembler}/illumina_run3_R2.bam",

    params:
          threads=32
    output:
          polished_assembly="results/Genomics/1_Assembly/2_Assemblers/pilon/{assembler}/assembly_polished.fasta"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/2_Assemblers/Polishing.py"

#Evaluation
rule quast:
    input:
         assembly="results/Genomics/1_Assembly/2_Assemblers/{assembler}/{process}/assembly.fasta",
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
         input_dir="results/Genomics/1_Assembly/3_Evaluation/",
    params:
          threads=32
    output:
          out_dir=directory("results/Genomics/1_Assembly/3_Evaluation/multiqc/{assembler}")
    conda:
         "envs/genomics.yaml"
    shell:
         'multiqc {input.input_dir} -o {output.out_dir}'

rule plot_coverage_cont:
    input:
         #coverage on assembley
         run1="results/Genomics/1_Assembly/3_Evaluation/bowtie2/paired/{assembler}/illumina_run1.bam",
         run2="results/Genomics/1_Assembly/3_Evaluation/bowtie2/paired/{assembler}/illumina_run2.bam",
         run3="results/Genomics/1_Assembly/3_Evaluation/bowtie2/paired/{assembler}/illumina_run3.bam",
         pac="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/pacbio.bam",
         nano="results/Genomics/1_Assembly/3_Evaluation/winnowmap/{assembler}/nanopore.bam"
    output:
          out="results/Genomics/1_Assembly/3_Evaluation/deeptools/{assembler}.png",
          outraw="results/Genomics/1_Assembly/3_Evaluation/deeptools/{assembler}/outRawCounts.txt"
    params:
          threads=32,
    # ill1_P = "ill1_P",
    # ill2_P = "ill2_P",
    # ill3_P = "ill3_P",
    #pac = "pac",
    #nano = "nano",
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/Genomics/1_Assembly/3_Evaluation/PlotCoverage.py"
