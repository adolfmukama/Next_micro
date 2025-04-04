process FILTLONG {
    tag "running filtlong"
    publishDir "${params.outdir}/filtlong_out", mode: 'copy'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/filtlong:0.2.1--h9a82719_0' :
        'biocontainers/filtlong:0.2.1--h9a82719_0' }"

    input:
    tuple val(sample_id), path(read1), path(read2), path(longread)

    output:
    tuple val(sample_id), path("*.fastq.gz"), emit: reads
    tuple val(sample_id), path("*.log")     , emit: log, optional:true
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    
    """
    filtlong \\
        --min_length 1000 \\
        --keep_percent 90 \\
        --target_bases 500000000 ${longread} | gzip > ${sample_id}.filt.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        filtlong: \$( filtlong --version | sed -e "s/Filtlong v//g" )
    END_VERSIONS
    """
}