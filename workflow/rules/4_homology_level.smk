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