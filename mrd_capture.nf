#!/usr/bin/env nextflow
nextflow.enable.dsl=2

log.info """
STARTING PIPELINE
=*=*=*=*=*=*=*=*=
Sample list: ${params.input}
Sequences in:${params.sequences}
"""

//file paths
genome_file = file("${params.genome}", checkIfExists: true)
index_files = file("${params.genome_dir}/${params.ind_files}.*")
dict_file = file("${params.genome_dir}/${params.ind_files}.dict")
bedfile = file("${params.bed_file}", checkIfExists: true)
collapsed = params.collapsed
uncollapsed = params.uncollapsed
mutect2 = params.mutect2
vardict = params.vardict
varscan = params.varscan

include { ADD_UMI } from './modules/fgbio/fastqtobam/main.nf'
include { MAPBAM; MAPBAM_CONS } from './modules/fgbio/mapbam/main.nf'
include { ZIPPERBAM } from './modules/fgbio/zipperbams/main.nf'
include { SORT_INDEX; SORT_INDEX_CONS } from './modules/samtools/sort_index/main.nf'
include { SPLITBAM } from './modules/samtools/splitbam/main.nf'
include { GROUPREADSBYUMI } from './modules/fgbio/groupreads/main.nf'
include { CALLMOLCONSREADS } from './modules/fgbio/callmolecularconsensus/main.nf'
include { COMBINEBAMS } from './modules/samtools/combinebams/main.nf'
include { FILTERCONSBAM } from './modules/fgbio/fiterconsbam/main.nf'
include { ADDGROUPS } from './modules/gatk/addreplacegroups/main.nf'
include { COVERAGE as COVERAGE_COLL; COVERAGE as  COVERAGE_UNCOLL } from './modules/bedtools/coverage/main.nf'
include { HSMETRICS as HSMETRICS_COLL; HSMETRICS as HSMETRICS_UNCOLL } from './modules/gatk/hsmetrics/main.nf'
include { MUTECT2 as MUTECT2_COLL; MUTECT2 as MUTECT2_UNCOLL; DICT_GEN } from './modules/gatk/mutect2/main.nf'
include { VARDICT as VARDICT_COLL; VARDICT as VARDICT_UNCOLL} from './modules/vardict/variantcall/main.nf'
include { MPILEUP as MPILEUP_COLL; MPILEUP as MPILEUP_UNCOLL } from './modules/samtools/mpileup/main.nf'
include { VARSCAN as VARSCAN_COLL; VARSCAN as VARSCAN_UNCOLL } from './modules/varscan/variantcall/main.nf'
include { ANNOVAR as ANNOVAR_COLL_MUTECT2; ANNOVAR as ANNOVAR_COLL_VARDICT; ANNOVAR as ANNOVAR_COLL_VARSCAN } from './modules/annovar/annotate/main.nf'
include { ANNOVAR as ANNOVAR_UNCOLL_MUTECT2; ANNOVAR as ANNOVAR_UNCOLL_VARDICT; ANNOVAR as ANNOVAR_UNCOLL_VARSCAN } from './modules/annovar/annotate/main.nf'
include { COMBINE_CALLERS as COMBINE_CALLERS_COLL; COMBINE_CALLERS as COMBINE_CALLERS_UNCOLL} from './modules/python/combine/main.nf'

workflow MRD_PROBE {
	Channel.fromPath(params.input)
		.splitCsv(header:false)
		.map { row ->
			def sample = row[0].trim()
			def r1 = file("${params.sequences}/${sample}_R1.fastq.gz", checkIfExists: false)
			def r2 = file("${params.sequences}/${sample}_R2.fastq.gz", checkIfExists: false)
			def umi = file("${params.sequences}/${sample}_UMI_R1.fastq.gz", checkIfExists: false)
			tuple(sample, r1, r2, umi)
		}
		.set { bam_ch }
	main:
	DICT_GEN(genome_file)
	ADD_UMI(bam_ch)
	MAPBAM(ADD_UMI.out, genome_file, index_files)
	ZIPPERBAM(MAPBAM.out, genome_file, index_files)
	SORT_INDEX(ZIPPERBAM.out)
	SPLITBAM(SORT_INDEX.out, bedfile)
	GROUPREADSBYUMI(SPLITBAM.out.chrwise_bamlist)
	CALLMOLCONSREADS(GROUPREADSBYUMI.out.grouped_bam_ch, genome_file, index_files)
	COMBINEBAMS (CALLMOLCONSREADS.out.consensus_bam_ch)
	MAPBAM_CONS (COMBINEBAMS.out.combined_bam_ch, genome_file, index_files)
	FILTERCONSBAM (MAPBAM_CONS.out, genome_file, index_files)
	ADDGROUPS (FILTERCONSBAM.out)
	SORT_INDEX_CONS (ADDGROUPS.out)
	
	HSMETRICS_COLL(SORT_INDEX_CONS.out, bedfile, genome_file, index_files, collapsed)
	HSMETRICS_UNCOLL(SORT_INDEX.out, bedfile, genome_file, index_files, uncollapsed)

	COVERAGE_COLL(SORT_INDEX_CONS.out, bedfile, collapsed)
	COVERAGE_UNCOLL(SORT_INDEX.out, bedfile, uncollapsed)

	MUTECT2_COLL(SORT_INDEX_CONS.out, bedfile, genome_file, DICT_GEN.out, index_files, collapsed)
	MUTECT2_UNCOLL(SORT_INDEX.out, bedfile, genome_file, DICT_GEN.out, index_files, uncollapsed)

	VARDICT_COLL(SORT_INDEX_CONS.out, bedfile, genome_file, DICT_GEN.out, index_files, collapsed)
	VARDICT_UNCOLL(SORT_INDEX.out, bedfile, genome_file, DICT_GEN.out, index_files, uncollapsed)

	MPILEUP_COLL(SORT_INDEX_CONS.out, bedfile, genome_file, DICT_GEN.out, index_files, collapsed)
	VARSCAN_COLL(SORT_INDEX_CONS.out.join(MPILEUP_COLL.out), bedfile, genome_file, DICT_GEN.out, index_files, collapsed)

	MPILEUP_UNCOLL(SORT_INDEX.out, bedfile, genome_file, DICT_GEN.out, index_files, uncollapsed)
	VARSCAN_UNCOLL(SORT_INDEX.out.join(MPILEUP_UNCOLL.out), bedfile, genome_file, DICT_GEN.out, index_files, uncollapsed)

	ANNOVAR_COLL_MUTECT2(MUTECT2_COLL.out, mutect2)
	ANNOVAR_COLL_VARDICT(VARDICT_COLL.out, vardict)
	ANNOVAR_COLL_VARSCAN(VARSCAN_COLL.out, varscan)

	ANNOVAR_UNCOLL_MUTECT2(MUTECT2_UNCOLL.out, mutect2)
	ANNOVAR_UNCOLL_VARDICT(VARDICT_UNCOLL.out, vardict)
	ANNOVAR_UNCOLL_VARSCAN(VARSCAN_UNCOLL.out, varscan)

	COMBINE_CALLERS_COLL(ANNOVAR_COLL_MUTECT2.out.join(ANNOVAR_COLL_VARDICT.out.join(ANNOVAR_COLL_VARSCAN.out.join(COVERAGE_COLL.out))), collapsed)
	COMBINE_CALLERS_UNCOLL(ANNOVAR_UNCOLL_MUTECT2.out.join(ANNOVAR_UNCOLL_VARDICT.out.join(ANNOVAR_UNCOLL_VARSCAN.out.join(COVERAGE_UNCOLL.out))), uncollapsed)
}

workflow.onComplete {
	log.info ( workflow.success ? "\n\nDone! Output in the 'Final_Output' directory \n" : "Oops .. something went wrong" )
	log.info ("Completed at: ${workflow.complete}")
	log.info ("Total time taken: ${workflow.duration}")
}
