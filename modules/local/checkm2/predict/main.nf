/*

checkm2 module 

*/

process  CHECKM2 {
    tag "running checkm2"
    publishDir "${params.outdir}/checkm2_out", mode: 'copy'

    conda "${moduleDir}/environment.yml"
    
    container "${ workflow.containerEngine == 'singularity' ?
       "docker://staphb/checkm2:latest" :
       "staphb/checkm2:latest" }"

    input:
    path(fasta, stageAs: "input_bins/*")
    path(db)

    output:
    path("${prefix}")                   , emit: checkm2_output
    path("${prefix}_checkm2_report.tsv"), emit: checkm2_tsv
    path("versions.yml")                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "checkm2"
    """
    checkm2 \\
        predict \\
        --input ${fasta} \\
        --output-directory ${prefix} \\
        --threads ${task.cpus} \\
        --database_path ${db} \\
        ${args}

    cp ${prefix}/quality_report.tsv ${prefix}_checkm2_report.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkm2: \$(checkm2 --version)
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p ${prefix}/diamond_output ${prefix}/protein_files
    touch ${prefix}/quality_report.tsv ${prefix}/checkm2.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkm2: \$(checkm2 --version)
    END_VERSIONS
    """
}