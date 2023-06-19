nextflow.enable.dsl=2


workflow dump_fastq{
    fastq_dump_reads()
}

process fastq_dump_reads {
    tag "$name"
    //container = 'quay.io/eqtlcatalogue/rnaseq:v20.11.1'

    input:
    tuple val(name), file(sra) 

    output:
    tuple val(name), file("*.fastq"), emit: fastq_reads

    script:
    """
    fasterq-dump -3 $sra
    """
}
