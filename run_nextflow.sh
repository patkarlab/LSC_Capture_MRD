#!/usr/bin/bash
##BSUB -J smMIPS_pipeline
##BSUB -n 25
##BSUB -q normal
##-m cn2" to submit jobs to cn2
## or " -m cn3"

##########
#for ENTRY : BEDFILES#
##for LEUKEMIA/MIPS: /home/pipelines/mutation_detector_nextflow/bedfile/06112021_Leukemia_Panel_sorted
##for MIPS (IDT-MRD): /home/pipelines/mutation_detector_nextflow/bedfile/04243058_MRD_Panel_V1_final_sorted 
##for CNVpanel+ALP:/home/pipelines/mutation_detector_nextflow/bedfile/ALP_CNV_backbone_sorted
##for CNVpanel:/home/pipelines/mutation_detector_nextflow/bedfile/xgen-human-cnv-backbone-hyb-panel-probes
##for Lungpanel:/home/pipelines/mutation_detector_nextflow/bedfile/lung_panel_egfr_kras_tp53_sortd
##for Twistmyeloid:/home/pipelines/mutation_detector_nextflow/bedfile/Leukemia_Bed_file_MYFU_grch37_sorted
##for Twistlymphoid:/home/pipelines/mutation_detector_nextflow/bedfile/Leukemia_Bedfile_ALL_grch37hglft_genome_ucsc
##for combined_panel:/home/pipelines/mutation_detector_nextflow/bedfile/Leukemia_Panel_Myeloid_2023_Feb_hg37_sortd
##for multiple_myeloma:/home/pipelines/mutation_detector_nextflow/bedfile/myeloma_combined_sortd

#echo "WARNING : change the bedfile and the cnv reference"
# for cnvkit reference 
# 06112021_Leukemia_Panel_sorted.bed : "/home/pipelines/NextSeq_mutation_detector_leukemia/scripts/cnvkit_ref_GeneNames/Reference_labelled.cnn" 
# Leukemia_Panel_Myeloid_2023_Feb_hg37_sortd.bed : "/home/pipelines/NextSeq_mutation_detector_leukemia/scripts/cnvkit_combpanel/Reference_combpanel.cnn"


#source activate new_base
#nextflow -c /home/diagnostics/pipelines/Validation/nextflow.config run validation.nf -entry  VALIDATION \
#--bedfile /home/pipelines/mutation_detector_nextflow/bedfile/CNV_Small_TALL_RNA_DNA_IGVH_sortd \
#--cnvkitRef /home/pipelines/MMpanel/scripts/cnvkit_cnvmyeloid/Reference_combpanel.cnn \
#--gene_scatter_list /home/pipelines/MMpanel/scripts/cnvkit_cnvmyeloid \
#--sequences /home/diagnostics/pipelines/Validation/sequences/ \
#--input /home/diagnostics/pipelines/Validation/samplesheet.csv \
#-resume -bg
#conda deactivate 
#change bedfile name,without .bed extension

# For CNV myeloid panel
#source activate new_base
#nextflow -c  /home/diagnostics/pipelines/Validation/nextflow.config run validation.nf -entry VALIDATION \
#--bedfile /home/pipelines/mutation_detector_nextflow/bedfile/CNV_Small_hg19_newmyeloid_sortd \
#--cnvkitRef /home/pipelines/MMpanel/scripts/cnvkit_cnvmyeloid/Reference_combpanel.cnn \
#--gene_scatter_list /home/pipelines/MMpanel/scripts/cnvkit_cnvmyeloid \
#--sequences /home/diagnostics/pipelines/Validation/sequences/ \
#--input /home/diagnostics/pipelines/Validation/samplesheet.csv \
#-resume -bg
#conda deactivate

#source activate new_base
#nextflow -c /home/diagnostics/pipelines/Validation/nextflow.config run validation.nf -entry  VALIDATION \
#--bedfile /home/pipelines/mutation_detector_nextflow/bedfile/TALL_RNA_DNA_comb_hg19_sortd \
#--trans_bedfile /home/pipelines/MMpanel/bedfiles/MMPanel_translocation_sortd \
#--cnvkitRef /home/pipelines/NextSeq_mutation_detector_leukemia/scripts/cnvkit_mmpanel/Reference_combpanel.cnn \
#--sequences /home/diagnostics/pipelines/Validation/sequences/ \
#--input /home/diagnostics/pipelines/Validation/samplesheet.csv \
#-resume -bg
#conda deactivate

# For CNV Small panel
#source activate new_base
#nextflow -c  /home/diagnostics/pipelines/Validation/nextflow.config run validation.nf -entry VALIDATION \
#--bedfile /home/pipelines/MMpanel/bedfiles/CNV_Small_hg19_sortd \
#--cnvkitRef /home/pipelines/NextSeq_mutation_detector_leukemia/scripts/cnvkit_mmpanel/Reference_combpanel.cnn \
#--gene_scatter_list /home/pipelines/MMpanel/scripts/cnvkit_mmpanel \
#--sequences /home/diagnostics/pipelines/Validation/sequences/ \
#--input /home/diagnostics/pipelines/Validation/samplesheet.csv \
#-resume -bg
#conda deactivate

# For NPM1-FLT3 amplicon MRD - Diagnostics
#source activate new_base
#nextflow -c /home/diagnostics/pipelines/Validation/nextflow.config run npm1_mrd_diag.nf -entry NPM1 \
#--sequences /home/diagnostics/pipelines/Validation/sequences/ \
#--input /home/diagnostics/pipelines/Validation/samplesheet.csv \
#--bedfile /home/diagnostics/pipelines/Validation/bedfiles/NPM1_FLT3 \
#-resume -bg


# For NPM1 amplicon MRD
source activate new_base

nextflow -c /home/diagnostics/pipelines/Validation/nextflow.config run npm1_mrd.nf -entry NPM1_MRD \
--sequences /home/diagnostics/pipelines/Validation/sequences/ \
--input /home/diagnostics/pipelines/Validation/samplesheet.csv \
--bedfile /home/diagnostics/pipelines/Validation/bedfiles/NPM1_FLT3 \
-resume -bg

conda deactivate

# For FLT3 amplicon MRD
#source activate new_base

#nextflow -c /home/diagnostics/pipelines/Validation/nextflow.config run npm1_mrd.nf -entry FLT3_MRD \
#--sequences /home/diagnostics/pipelines/Validation/sequences/ \
#--input /home/diagnostics/pipelines/Validation/samplesheet.csv \
#--bedfile /home/diagnostics/pipelines/Validation/bedfiles/NPM1_FLT3 \
#-profile docker -resume -bg

#conda deactivate


#Validation
#source activate new_base
#nextflow -c /home/diagnostics/pipelines/Validation/nextflow.config run validation.nf -entry TEST \
#--sequences /home/diagnostics/pipelines/Validation/sequences/ \
#--input /home/diagnostics/pipelines/Validation/samplesheet.csv \
#-profile docker -resume -bg
#conda deactivate


# VALIDATION v2
#source activate new_base

#nextflow -c /home/diagnostics/pipelines/Validation/nextflow.config run npm1_mrd.nf -entry NPM1_MRD \
#--sequences /home/diagnostics/pipelines/Validation/sequences/ \
#--input /home/diagnostics/pipelines/Validation/samplesheet.csv \
#--bedfile /home/pipelines/Consensus_pipeline_with_espresso/bedfiles/CEBPA_01122025_sortd \
#-resume -bg

#conda deactivate

