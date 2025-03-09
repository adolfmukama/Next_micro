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
    path("multiqc_report.html"), emit: html
    path("multiqc_data"), emit: data

    script:
    """ 
    multiqc ${html}

    """
}