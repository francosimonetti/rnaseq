nextflow.enable.dsl=2

forward_stranded = params.forward_stranded
reverse_stranded = params.reverse_stranded
unstranded = params.unstranded

/*
 * STEP 2 - Trim Galore!
 */
process trim_galore {
    tag "$name"
    publishDir "${params.outdir}/trim_galore", mode: 'copy', pattern: "*fq.gz", enabled: params.saveTrimmed
    publishDir "${params.outdir}/trim_galore/logs", mode: 'copy', pattern: "*trimming_report.txt" , enabled: params.saveInfoLogs
    publishDir "${params.outdir}/trim_galore/FastQC", mode: 'copy', pattern: "*_fastqc.{zip,html}"  , enabled: params.saveInfoLogs
    container = 'quay.io/eqtlcatalogue/rnaseq:v20.11.1'

    input:
    tuple val(name), file(reads) 

    output:
    tuple val(name), file("*fq.gz"), emit: trimmed_reads
    path "*trimming_report.txt" 
    path "*_fastqc.{zip,html}" 

    script:
    // Clipping presets have to be evaluated in the context of SE/PE
    def c_r1   = params.clip_r1 > 0             ? "--clip_r1 ${params.clip_r1}"                         : ''
    def c_r2   = params.clip_r2 > 0             ? "--clip_r2 ${params.clip_r2}"                         : ''
    def tpc_r1 = params.three_prime_clip_r1 > 0 ? "--three_prime_clip_r1 ${params.three_prime_clip_r1}" : ''
    def tpc_r2 = params.three_prime_clip_r2 > 0 ? "--three_prime_clip_r2 ${params.three_prime_clip_r2}" : ''
    if (params.singleEnd) {
        """
        trim_galore --fastqc --gzip $c_r1 $tpc_r1 $reads
        """
    } else {
        """
        trim_galore --paired --fastqc --gzip $c_r1 $c_r2 $tpc_r1 $tpc_r2 $reads
        """
    }
}

process makeHisatSplicesites {
    tag "$gtf"
    publishDir "${params.outdir}/reference_genome/", mode: 'copy', enabled: params.saveReference
    container = 'quay.io/eqtlcatalogue/rnaseq_hisat2:v22.03.01'

    input:
    path gtf 

    output:
    path "${gtf.baseName}.hisat2_splice_sites.txt" 

    script:
    """
    hisat2_extract_splice_sites.py $gtf > ${gtf.baseName}.hisat2_splice_sites.txt
    """
}

process makeHISATindex {
    tag "$fasta"
    publishDir "${params.outdir}/reference_genome/hisat2", mode: 'copy', enabled: params.saveReference
    container = 'quay.io/eqtlcatalogue/rnaseq_hisat2:v22.03.01'

    input:
    path fasta 
    path indexing_splicesites 
    path gtf 

    output:
    path "${fasta.baseName}.*.ht2"

    script:
    if( !task.memory ){
        log.info "[HISAT2 index build] Available memory not known - defaulting to 0. Specify process memory requirements to change this."
        avail_mem = 0
    } else {
        log.info "[HISAT2 index build] Available memory: ${task.memory}"
        avail_mem = task.memory.toGiga()
    }
    if( avail_mem > params.hisatBuildMemory ){
        log.info "[HISAT2 index build] Over ${params.hisatBuildMemory} GB available, so using splice sites and exons in HISAT2 index"
        extract_exons = "hisat2_extract_exons.py $gtf > ${gtf.baseName}.hisat2_exons.txt"
        ss = "--ss $indexing_splicesites"
        exon = "--exon ${gtf.baseName}.hisat2_exons.txt"
    } else {
        log.info "[HISAT2 index build] Less than ${params.hisatBuildMemory} GB available, so NOT using splice sites and exons in HISAT2 index."
        log.info "[HISAT2 index build] Use --hisatBuildMemory [small number] to skip this check."
        extract_exons = ''
        ss = ''
        exon = ''
    }
    """
    $extract_exons
    hisat2-build -p ${task.cpus} $ss $exon $fasta ${fasta.baseName}.hisat2_index
    """
}

process hisat2Align {
    tag "$samplename"
    publishDir "${params.outdir}/HISAT2/logs/", mode: 'copy', pattern: "*.hisat2_summary.txt", enabled: params.saveInfoLogs
    publishDir "${params.outdir}/HISAT2/aligned/", mode: 'copy', pattern: "*.bam", enabled: params.saveAlignedIntermediates
    container = 'quay.io/eqtlcatalogue/rnaseq_hisat2:v22.03.01'

    input:
    tuple val(samplename), file(reads) 
    path hs2_indices
    path alignment_splicesites

    output:
    path "${samplename}.bam", emit: hisat2_bam_ch
    path "${samplename}.hisat2_summary.txt"

    script:
    index_base = hs2_indices[0].toString() - ~/.\d.ht2/
    seqCenter = params.seqCenter ? "--rg-id ${samplename} --rg CN:${params.seqCenter.replaceAll('\\s','_')}" : ''
    def rnastrandness = ''
    if (forward_stranded && !unstranded){
        rnastrandness = params.singleEnd ? '--rna-strandness F' : '--rna-strandness FR'
    } else if (reverse_stranded && !unstranded){
        rnastrandness = params.singleEnd ? '--rna-strandness R' : '--rna-strandness RF'
    }
    if (params.singleEnd) {
        """
        hisat2 -x $index_base \\
                -U $reads \\
                $rnastrandness \\
                --known-splicesite-infile $alignment_splicesites \\
                -p ${task.cpus} \\
                --met-stderr \\
                --new-summary \\
                --summary-file ${samplename}.hisat2_summary.txt $seqCenter \\
                | samtools view -bS -F 4 -F 256 - > ${samplename}.bam
        """
    } else {
        """
        # localTMPDIR=/tmp/`tr -dc A-Za-z0-9 </dev/urandom | head -c 13`
        # mkdir -p \$localTMPDIR
        # --temp-directory "\${localTMPDIR}" \\
        hisat2 -x $index_base \\
                -1 ${reads[0]} \\
                -2 ${reads[1]} \\
                $rnastrandness \\
                --known-splicesite-infile $alignment_splicesites \\
                --no-mixed \\
                --no-discordant \\
                -p ${task.cpus} \\
                --met-stderr \\
                --new-summary \\
                --summary-file ${samplename}.hisat2_summary.txt $seqCenter \\
                | samtools view -bS -F 4 -F 8 -F 256 - > ${samplename}.bam
        """
    }
}

process hisat2_sortOutput {
    tag "${hisat2_bam.baseName}"
    publishDir "${params.outdir}/HISAT2/aligned_sorted", mode: 'copy', enabled: params.saveAlignedIntermediates
    container = 'quay.io/eqtlcatalogue/rnaseq:v20.11.1'

    input:
    path hisat2_bam

    output:
    tuple file("${hisat2_bam.baseName}.sorted.bam"), file("${hisat2_bam.baseName}.sorted.bam.bai"), emit: bam_sorted_indexed

    script:
    def avail_mem = task.memory ? "-m ${task.memory.toBytes() / task.cpus}" : ''
    """
    samtools sort \\
        $hisat2_bam \\
        -@ ${task.cpus} $avail_mem \\
        -o ${hisat2_bam.baseName}.sorted.bam
    samtools index ${hisat2_bam.baseName}.sorted.bam
    """
}

process sort_by_name_BAM {
    tag "${bam.baseName - '.sorted'}"
    container = 'quay.io/eqtlcatalogue/rnaseq:v20.11.1'

    input:
    tuple file(bam), file(bam_index)

    output:
    path "${bam.baseName}ByName.bam", emit: bam_sorted_by_name
    
    script:
    def avail_mem = task.memory ? "-m ${task.memory.toBytes() / (task.cpus + 2)}" : ''
    """
    samtools sort -n \\
        $bam \\
        -@ ${task.cpus} $avail_mem \\
        -o ${bam.baseName}ByName.bam
    """
}