nextflow.enable.dsl=2

process fastq_dump_reads {
    tag "$name"
    //publishDir "${params.outdir}/fastq", mode: 'copy', pattern: "*.fastq.gz"
    container = '774353128408.dkr.ecr.us-east-1.amazonaws.com/sra_fastq_dump_task'

    input:
    tuple val(name), file(sra)

    output:
    tuple val(name), file("*.fastq.gz"), emit: fastq_reads

    script:
    """
    echo "${name} \$PWD/${sra}"
 
#if [[ -f "/root/.ncbi/user-settings.mkfg" ]]; then

#if grep -q "remote/disabled" /root/.ncbi/user-settings.mkfg; then
#    cat /root/.ncbi/user-settings.mkfg
#    echo "We have been here!"
#fi
#else

    #rm /root/.ncbi/user-settings.mkfg
#    vdb-config --restore-defaults

 #   cp /root/.ncbi/user-settings.mkfg /root/.ncbi/user-settings.mkfg.old
 #   echo '/repository/remote/disabled = "true"' >> /root/.ncbi/user-settings.mkfg

    # This forces usage of a local refseq folder instead of pulling from NCBI every time
    # echo '/repository/site/main/archive/apps/refseq/volumes/refseq = "refseq"' >> /root/.ncbi/user-settings.mkfg
    #echo '/repository/site/main/archive/root = "PWD"' >> /root/.ncbi/user-settings.mkfg
    #sed "s:PWD:\$PWD:" /root/.ncbi/user-settings.mkfg > /root/.ncbi/user-settings.mkfg.tmp
    #sleep 0.\$((9000 + RANDOM%600))
    #if [[ ! -f "/root/.ncbi/updated" ]]; then
     #   if [[ -f "/root/.ncbi/user-settings.mkfg.tmp" ]]; then
      #      mv /root/.ncbi/user-settings.mkfg.tmp /root/.ncbi/user-settings.mkfg
       # fi
      #  touch /root/.ncbi/updated
    #fi
#fi

    #vdb-config -s "/repository/remote/disabled=true"
    cp $sra "my_local_file.sra"
    #if [ "${name}" = "SRR2167898" ]; then 
    fastq-dump --split-3 "my_local_file.sra"
    #else
    #fasterq-dump -3 "my_local_file.sra"
    #fi
    ls
    pwd
    mv "my_local_file_1.fastq" ${name}_1.fastq
    mv "my_local_file_2.fastq" ${name}_2.fastq
    ls
    rm "my_local_file.sra"
    pigz -c ${name}_1.fastq > ${name}_1.fastq.gz
    rm ${name}_1.fastq
    pigz -c ${name}_2.fastq > ${name}_2.fastq.gz
    rm ${name}_2.fastq
    """
}
