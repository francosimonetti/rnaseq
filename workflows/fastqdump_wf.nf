nextflow.enable.dsl=2

process fastq_dump_reads {
    tag "$name"
    publishDir "${params.outdir}/fastq", mode: 'copy', pattern: "*.fastq"
    //container = 'quay.io/eqtlcatalogue/rnaseq:v20.11.1'

    input:
    tuple val(name), file(sra) 

    output:
    tuple val(name), file("*.fastq"), emit: fastq_reads

    script:
    """
    fasterq-dump -3 ./$sra
    """
}
