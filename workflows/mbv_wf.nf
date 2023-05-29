nextflow.enable.dsl=2

Channel
    .fromPath(params.mbv_vcf)
    .ifEmpty { exit 1, "VCF file is not found to perform MBV: ${params.mbv_vcf}" }
    .set { mbv_vcf_ch }

Channel
    .fromPath(params.mbv_vcf_index)
    .ifEmpty { exit 1, "VCF index file is not found to perform MBV: ${params.mbv_vcf_index}" }
    .set { mbv_vcf_index_ch }

include { run_mbv } from '../modules/utils'

workflow generate_mbv {
    take:
        bam_sorted_indexed

    main:
        run_mbv(bam_sorted_indexed, mbv_vcf_ch.collect(), mbv_vcf_index_ch.collect())
}


