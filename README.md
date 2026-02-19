To run the workflow:

conda install bioconda::bwa
conda install agbiome::bbtools

bwa index AMR-reference.fasta

For sh file:

chmod +x run_pipeline.sh
./run_pipeline_threads.sh <fastq_directory> amr_reference.fasta <threads>

For go file:
go run finalrun_pileup.go <fastq directory> <AMR-reference> <threads>
