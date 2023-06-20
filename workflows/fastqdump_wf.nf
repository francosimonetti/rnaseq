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
    fasterq-dump -3 \$PWD/$sra
    pigz -c ${name}_1.fastq > ${name}_1.fastq.gz
    pigz -c ${name}_2.fastq > ${name}_2.fastq.gz
    rm ${name}_1.fastq ${name}_2.fastq
    """
}
