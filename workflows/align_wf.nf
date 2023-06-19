nextflow.enable.dsl=2

if(params.hisat2_index) {
    hs2_indices = Channel
        .fromPath("${params.hisat2_index}*")
        .ifEmpty { exit 1, "HISAT2 index not found: ${params.hisat2_index}" }
} else {
    fasta_for_hisat2_index = Channel
        .fromPath(params.fasta)
        .ifEmpty { exit 1, "Fasta file not found: ${params.fasta}" }
}

if(params.readSRRAccFile) {
    Channel.fromPath(params.readSRRAccFile)
    .ifEmpty { error "Cannot find any readSRRAccFile file in: ${params.readSRRAccFile}" }
    .splitCsv(header: false, sep: '\t', strip: true)
    .map{row -> [ row[0], file(row[1]) ]}
    .set { raw_sra_run }

} else {
    if(params.singleEnd){
        Channel.fromPath(params.readPathsFile)
        .ifEmpty { error "Cannot find any readPathsFile file in: ${params.readPathsFile}" }
        .splitCsv(header: false, sep: '\t', strip: true)
        .map{row -> [ row[0], [ file(row[1]) ] ]}
        .set { raw_reads_trimgalore }
    } else {
        Channel.fromPath(params.readPathsFile)
        .ifEmpty { error "Cannot find any readPathsFile file in: ${params.readPathsFile}" }
        .splitCsv(header: false, sep: '\t', strip: true)
        .map{row -> [ row[0], [ file(row[1]) , file(row[2]) ] ]}
        .set { raw_reads_trimgalore }
    }
}

Channel
    .fromPath( params.gtf_hisat2_index )
    .ifEmpty { exit 1, "GTF annotation file for hisat index not found: ${params.gtf_hisat2_index}" }
    .set { gtf_file }

include { makeHisatSplicesites; trim_galore; makeHISATindex; hisat2Align; hisat2_sortOutput; sort_by_name_BAM } from '../modules/align'
include { fastq_dump_reads } from "./fastqdump_wf.nf"

workflow {
    align_reads()
}

workflow align_reads {
    main:
        makeHisatSplicesites(gtf_file.collect())
        if(params.readSRRAccFile){
            fastq_dump_reads(raw_sra_run)
            trim_galore(fastq_dump_reads.out.fastq_reads)
        } else {
            trim_galore(raw_reads_trimgalore)
        }
        if(!params.hisat2_index) {
            hs2_indices = makeHISATindex(fasta_for_hisat2_index.collect(), 
                                        makeHisatSplicesites.out.collect(),
                                        gtf_file.collect())
        }
        hisat2Align(trim_galore.out.trimmed_reads, hs2_indices.collect(), makeHisatSplicesites.out.collect())
        hisat2_sortOutput(hisat2Align.out.hisat2_bam_ch)
        sort_by_name_BAM(hisat2_sortOutput.out.bam_sorted_indexed)

    emit:
        bam_sorted_by_name = sort_by_name_BAM.out.bam_sorted_by_name
        trimmed_reads = trim_galore.out.trimmed_reads
        bam_sorted_indexed = hisat2_sortOutput.out.bam_sorted_indexed
}


