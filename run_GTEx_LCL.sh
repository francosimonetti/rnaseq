### inspect singularity containers with
nextflow inspect main.nf -profile fil_hpc

### Cache the containes in this pipeline
nextflow inspect -concretize main.nf -profile fil_hpc
## it doesn't work, but I can manually cache them with these commands:

singularity pull singularity_img/quay.io-eqtlcatalogue-rnaseq:v20.11.1.img docker://quay.io/eqtlcatalogue/rnaseq:v20.11.1
singularity pull singularity_img/quay.io-eqtlcatalogue-qtltools:v22.03.1 docker://quay.io/eqtlcatalogue/qtltools:v22.03.1
singularity pull singularity_img/quay.io-eqtlcatalogue-rnaseq_hisat2:v22.03.01 docker://quay.io/eqtlcatalogue/rnaseq_hisat2:v22.03.01

## Run the workflow on the cluster
### Re-RUN WITH GTEX SAMPLE SHORT NAME, otherwise MBV doesn't find the chr region for the sample
nextflow run main.nf -profile fil_hpc 
