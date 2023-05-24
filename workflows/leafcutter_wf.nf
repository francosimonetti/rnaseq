nextflow.enable.dsl=2

include { bam_to_junc; cluster_introns} from '../modules/leafcutter'

workflow quant_leafcutter {
    take:
        bam_sorted_indexed
    
    main:
        bam_to_junc(bam_sorted_indexed)
	bam_to_junc.out.map{it.toString()}.view()
	// This paths will fail if run on AWS, because we need a list of file paths into the "junction_files.txt"
	// but on amazon they should have s3:/ prefix, but leafcutter will not understand this
	// so only run leafcutter on a single machine locally or not run it alone
        cluster_introns(bam_to_junc.out.junc.map{it.toString()}.collectFile(name: 'junction_files.txt', newLine: true))
}

