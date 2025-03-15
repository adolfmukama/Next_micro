process PANAROO_RUN {
    tag "running panaroo"
    publishDir "${params.outdir}/panaroo_out", mode: 'copy'

    conda "${moduleDir}/environment.yml"
    
    container "${ workflow.containerEngine == 'singularity' ?
       "docker://staphb/panaroo:latest" :
       "staphb/panaroo:latest" }"

    input:
    path(gff, stageAs: "input_gff/*")

    output:
    tuple val(meta), path("results/*")                                      , emit: results
    tuple val(meta), path("results/core_gene_alignment.aln"), optional: true, emit: aln
    path "versions.yml"                                                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "pan_run"
    """
    panaroo \\
        $args \\
        -t $task.cpus \\
        -o results \\
        -i $gff

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        panaroo: \$(echo \$(panaroo --version 2>&1) | sed 's/^.*panaroo //' ))
    END_VERSIONS
    """
}