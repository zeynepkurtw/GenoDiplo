DATA
PE = aa 236 240 resources/RawData/DNA/clean/illumina_run1_R1.clean.fastq.gz resources/RawData/DNA/clean/illumina_run1_R2.clean.fastq.gz
PE = ab 229 232 resources/RawData/DNA/clean/illumina_run2_R1.clean.fastq.gz resources/RawData/DNA/clean/illumina_run2_R2.clean.fastq.gz
PE = ac 235 238 resources/RawData/DNA/clean/illumina_run3_R1.clean.fastq.gz resources/RawData/DNA/clean/illumina_run3_R2.clean.fastq.gz
PACBIO = resources/RawData/DNA/clean/pacbio.clean.fastq.gz #or nanopore or both
END

PARAMETERS
GRAPH_KMER_SIZE = auto
USE_LINKING_MATES = 0
CA_PARAMETERS =  cgwErrorRate=0.15
KMER_COUNT_THRESHOLD = 1
NUM_THREADS = 30
JF_SIZE = 1380000000
SOAP_ASSEMBLY = 0
FLYE_ASSEMBLY = 1
END