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

## MBV will fail if the genotypes do not match with respect to the reference genome. In this case "chr1" and "1".
## The reference genome provided here does not contain the 'chr' word
## So we make a special chromosome without the 'chr' and problem solved
echo "chr1 1" > map_chr1_to_1.txt
bcftools annotate --rename-chrs map_chr1_to_1.txt -Oz -o GTEx_Analysis_2021-02-11_v9_WholeGenomeSeq_944Indiv_Analysis_Freeze.SHAPEIT2_phased.chr1.biallelic.MAF_0.01.updated.for_MBV_nochr.vcf.gz GTEx_Analysis_2021-02-11_v9_WholeGenomeSeq_944Indiv_Analysis_Freeze.SHAPEIT2_phased.chr1.biallelic.MAF_0.01.updated.vcf.gz
bcftools index -t GTEx_Analysis_2021-02-11_v9_WholeGenomeSeq_944Indiv_Analysis_Freeze.SHAPEIT2_phased.chr1.biallelic.MAF_0.01.updated.for_MBV_nochr.vcf.gz