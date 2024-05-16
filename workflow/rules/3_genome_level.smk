#Genome Structure Level
rule build_database_repeatmodeler:
    input:
         genome="results/Genomics/1_Assembly/2_Assembly/pilon/{assembler}/assembly_polished.fasta",
    output:
          multiext("results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db",
                   ".nhr",
                   ".nnd",
                   ".nin",
                   ".nni",
                   ".nog",
                   ".nsq",
                   ".translation")
    params:
          db_name="results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/builddatabase.py"

rule repeatmodeler:
    input:
         db="results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db.nhr"
    output:
          "results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db-families.fasta"
    params:
          db_name="results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db",
          threads = 8,
          engine="ncbi"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/Repeatmodeler.py"

rule repeatmasker:
    input:
         genome="results/Genomics/1_Assembly/2_Assembly/pilon/{assembler}/assembly_polished.fasta",
         lib="results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RModeler/genome_db-families.fasta"
    output:
          directory("results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/RMasker")
    conda:
         "env/genomics.yaml"
    threads: 32
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/Repeatmasker.py"

rule tRNAscan:
    input:
         genome="results/Genomics/1_Assembly/2_Assembly/pilon/{assembler}/assembly_polished.fasta"
    params: threads=8
    output:
          tRNA="results/Genomics/1_Assembly/2_Assembly/{assembler}/genome.tRNAscan",
          stats="results/Genomics/1_Assembly/2_Assembly/{assembler}/genome.stats",
          gff="results/Genomics/1_Assembly/2_Assembly/{assembler}/genome.gff"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/tRNAscan.py"

rule tRNAscan_cov:
    input:
         genome="results/Genomics/1_Assembly/2_Assembly/pilon/{assembler}/assembly_polished.fasta"
    params: threads=8
    output:
          tRNA="results/Genomics/1_Assembly/2_Assembly/{assembler}/sensitive_search/genome.tRNAscan_cov",
          stats="results/Genomics/1_Assembly/2_Assembly/{assembler}/sensitive_search/genome.stats_cov"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/tRNAscan_cov.py"

rule barrnap:
    input:
         genome="results/Genomics/1_Assembly/2_Assembly/pilon/{assembler}/assembly_polished.fasta"
    output:
          gff="results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/genome.rrna.gff",
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/barrnap.py"

rule cdhit:
    input:
        genome = "results/Genomics/1_Assembly/2_Assembly/pilon/{assembler}/assembly_polished.fasta"
    params:
        threads=8
    output: "results/ComparativeGenomics/1_GenomeStructureLevel/{assembler}/genome_{n}.cdhit"
    conda:
         "env/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/1_GenomeStructureLevel/cdhit.py"
