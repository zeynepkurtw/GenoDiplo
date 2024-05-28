configfile: "config/config.yaml"
include: "rules/4_homology_level.smk"

rule all:
    input:
        #orthofinder
        "results/ComparativeGenomics/2_SequenceSimilarityLevel/"
        #orthofinder_rerun

rule orthofinder:
    input:
         proteome="resources/Orthofinder/sp/"
    output:
        directory('results/ComparativeGenomics/2_SequenceSimilarityLevel/')
    conda:
         "envs/genomics.yaml"
    script:
          "scripts/ComparativeGenomics/2_SequenceSimilarityLevel/Orthofinder.py"

rule orthofinder_rerun:
    input:
         new_sp="resources/Orthofinder/new_sp",
         old_sp="results/Genomics/3_ComparativeGenomicsAnalysis/2_SequenceSimilarityLevel/{assembler}/{annotation}/OrthoFinder/{results}/WorkingDirectory/"
    output:
          directory('results/Genomics/3_ComparativeGenomicsAnalysis/2_SequenceSimilarityLevel/{assembler}/{annotation}/{results}/new_sp')
    conda:
         "envs/genomics.yaml"
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