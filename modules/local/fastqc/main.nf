/*

FastQc module 

*/

process FASTQC {
    tag 'running fastqc'
    publishDir "${params.outdir}/fastqc_out", mode: 'copy'
    container "${ workflow.containerEngine == 'singularity' ?
        "docker://staphb/fastqc:latest"}:
        "staphb/fastqc:latest" }"

    

    
}
