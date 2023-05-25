#!/usr/bin/bash

mypath="/mnf/efs/fs1/rnaseq/"
#mypath="/data/franco/rnaseq/"


for f in `awk '{print $2}' $mypath/data/read_paths_GEUVADIS_GBR20.tsv`; do
    echo wget $f;
    echo \$HOME/miniconda/bin/aws s3 cp $( basename "$f" ) s3://fsimonetti-nfdata/fastqs/
    echo -e "$( basename "$f" | sed 's/.fastq.gz//')\ts3://fsimonetti-nfdata/fastqs/$( basename "$f" )" >> new_paths_fastq1
done;

for f in `awk '{print $3}' $mypath/data/read_paths_GEUVADIS_GBR20.tsv`; do
    echo wget $f;
    echo \$HOME/miniconda/bin/aws s3 cp $( basename "$f" ) s3://fsimonetti-nfdata/fastqs/
    echo -e "s3://fsimonetti-nfdata/fastqs/$( basename "$f" )" >> new_paths_fastq2
done;

paste new_paths_fastq1 new_paths_fastq2 >> s3_paths.txt
