/*

FastQc module 

*/

process FASTQC {
    tag "running fastqc"
    publishDir "${params.outdir}/fastqc_out", mode: 'copy'

    conda (params.enable_conda ? "bioconda::fastqc=0.12.1" : null)
    
    container "${ workflow.containerEngine == 'singularity' ?
       "docker://staphb/fastqc:latest" :
       "staphb/fastqc:latest" }"

    input:
    tuple val(sample_id), path(read1), path(read2), path(longread)

    output:
    tuple val(sample_id), path("*.html"), emit: html
    //tuple val(sample_id), path("*.json"), emit: json
    tuple val(sample_id), path("*.zip"), emit: zip

    script:
    """
    fastqc ${read1} ${read2} -o ./

    """
}