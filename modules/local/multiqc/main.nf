/*

MultiQc module 

*/

process MULTIQC {
    tag "running multiqc"
    publishDir "${params.outdir}/multiqc_out", mode: 'copy'

    conda "${moduleDir}/environment.yml"
    
    container "${ workflow.containerEngine == 'singularity' ?
       "docker://staphb/multiqc:latest" :
       "staphb/multiqc:latest" }"

    input:
    path html

    output:
    path("*_report.html"), emit: html
    path("*_data"), emit: data

    script:
    """ 
    multiqc ${html}

    """
}