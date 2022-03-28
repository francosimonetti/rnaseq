### Introduction

**eQTL-Catalogue/rnaseq** is a bioinformatics analysis pipeline used for processing RNA-sequencing data for the eQTL Catalogue.

The workflow processes raw data from fastq inputs ([Trim Galore!](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)); aligns the reads ([HiSAT2](https://ccb.jhu.edu/software/hisat2/index.shtml)); generates gene and exon counts ([featureCounts](http://bioinf.wehi.edu.au/featureCounts/), [DEXSeq](https://bioconductor.org/packages/release/bioc/html/DEXSeq.html)); quantifes transcript usage ([Salmon](https://combine-lab.github.io/salmon/)), transcriptional event usage ([txrevise](https://github.com/kauralasoo/txrevise)) and splice junction usage ([leafcutter](https://davidaknowles.github.io/leafcutter/)); and check concordance between genotypes in BAM and VCF files ([qtltools mbv](https://qtltools.github.io/qtltools/)). See the [output documentation](docs/output.md) for more details of the results.

See [optional quantification methods](docs/extra_phenotype_quantification.md) for details.

The pipeline is built using [Nextflow](https://www.nextflow.io), a bioinformatics workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It comes with docker / singularity containers making installation trivial and results highly reproducible.

### Documentation
The eQTL-Catalogue/rnaseq pipeline comes with documentation about the pipeline, found in the `docs/` directory:

1. [Installation](docs/installation.md)
2. Pipeline configuration
    * [Local installation](docs/configuration/local.md)
    * [Amazon Web Services (aws)](docs/configuration/aws.md)
    * [Swedish UPPMAX clusters](docs/configuration/uppmax.md)
    * [Swedish cs3e Hebbe cluster](docs/configuration/c3se.md)
    * [Tübingen QBiC](docs/configuration/qbic.md)
    * [CCGA Kiel](docs/configuration/ccga.md)
    * [Adding your own system](docs/configuration/adding_your_own.md)
3. [Running the pipeline (Gene expression)](docs/usage.md)
4. [Running the pipeline (With additional quantification methods)](docs/extra_phenotype_quantification.md)
5. [Output and how to interpret the results](docs/output.md)
6. [Troubleshooting](docs/troubleshooting.md)

### General overview 
The schema shown below represents the high level structure of the pipeline.
# ![nfcore/rnaseq](docs/images/pipeline_high_level_schema.svg)

### Credits
These scripts were originally written for use at the [National Genomics Infrastructure](https://portal.scilifelab.se/genomics/), part of [SciLifeLab](http://www.scilifelab.se/) in Stockholm, Sweden, by Phil Ewels ([@ewels](https://github.com/ewels)) and Rickard Hammarén ([@Hammarn](https://github.com/Hammarn)).

Many thanks to other who have helped out along the way too, including (but not limited to):
[@Galithil](https://github.com/Galithil),
[@pditommaso](https://github.com/pditommaso),
[@orzechoj](https://github.com/orzechoj),
[@apeltzer](https://github.com/apeltzer),
[@colindaven](https://github.com/colindaven).
