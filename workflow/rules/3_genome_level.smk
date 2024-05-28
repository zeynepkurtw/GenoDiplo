#Genome Structure Level
rule build_database_repeatmodeler:
    input:
         genome="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
    output:
          multiext("results/ComparativeGenomics/1_GenomeStructureLevel/RModeler/{assembler}/genome_db",
                   ".nhr",
                   ".nnd",
                   ".nin",
                   ".nni",
                   ".nog",
                   ".nsq",
                   ".translation")
    params:
          db_name="results/ComparativeGenomics/1_GenomeStructureLevel/RModeler/{assembler}/genome_db"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/builddatabase.py"

rule repeatmodeler:
    input:
         db="results/ComparativeGenomics/1_GenomeStructureLevel/RModeler/{assembler}/genome_db.nhr"
    output:
          "results/ComparativeGenomics/1_GenomeStructureLevel/RModeler/{assembler}/genome_db-families.fasta"
    params:
          db_name="results/ComparativeGenomics/1_GenomeStructureLevel/RModeler/{assembler}/genome_db",
          threads = 32,
          engine="ncbi"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/Repeatmodeler.py"

rule repeatmasker:
    input:
         genome="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta",
         lib="results/ComparativeGenomics/1_GenomeStructureLevel/RModeler/{assembler}/genome_db-families.fasta"
    output:
          directory("results/ComparativeGenomics/1_GenomeStructureLevel/RMasker/{assembler}")
    conda:
         "envs/genomics.yaml"
    threads: 32
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/Repeatmasker.py"

rule tRNAscan:
    input:
         genome="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta"
    params: threads=32
    output:
          tRNA="results/Genomics/1_Assembly/2_Assemblers/tRNAscan/{assembler}/genome.tRNAscan",
          stats="results/Genomics/1_Assembly/2_Assemblers/tRNAscan/{assembler}/genome.stats",
          gff="results/Genomics/1_Assembly/2_Assemblers/tRNAscan/{assembler}/genome.gff"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/tRNAscan.py"

rule tRNAscan_cov:
    input:
         genome="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta"
    params: threads=32
    output:
          tRNA="results/Genomics/1_Assembly/2_Assemblers/tRNAscan/sensitive_search/{assembler}/genome.tRNAscan_cov",
          stats="results/Genomics/1_Assembly/2_Assemblers/tRNAscan/sensitive_search/{assembler}/genome.stats_cov"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/tRNAscan_cov.py"

rule barrnap:
    input:
         genome="results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta"
    output:
          gff="results/ComparativeGenomics/1_GenomeStructureLevel/barrnap/{assembler}/genome.rrna.gff",
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/barrnap.py"

rule cdhit:
    input:
        genome = "results/Genomics/1_Assembly/2_Assemblers/{assembler}/assembly.fasta"
    params:
        threads=32
    output: "results/ComparativeGenomics/1_GenomeStructureLevel/cdhit/{assembler}/genome_{n}.cdhit"
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/cdhit.py"
