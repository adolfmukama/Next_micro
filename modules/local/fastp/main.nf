/*

Fastp module 

*/

process FASTP {
    tag "running fastp"
    publishDir "${params.outdir}/fastp_out", mode: 'copy'

    conda "${moduleDir}/environment.yml"
    
    container "${ workflow.containerEngine == 'singularity' ?
       "docker://staphb/fastp:latest" :
       "staphb/fastp:latest" }"

    input:
    tuple val(sample_id), path(read1), path(read2), path(longread)

    output:
    tuple val(sample_id), 
          path("${sample_id}_filt_fastp_1.fastq.gz"),
          path("${sample_id}_filt_fastp_2.fastq.gz"), emit: reads
    path "*.json", emit: json
    path "*.html", emit: html

    script:
    """
    echo "Processing sample_id: ${sample_id}"
    fastp \
        -i ${read1} \
        -I ${read2} \
        -o ${sample_id}_filt_fastp_1.fastq.gz \
        -O ${sample_id}_filt_fastp_2.fastq.gz \
        --json ${sample_id}_filt_fastp.json \
        --html ${sample_id}_filt_fastp.html \
        -q 20 --thread 24 \
        --detect_adapter_for_pe
    """
}
