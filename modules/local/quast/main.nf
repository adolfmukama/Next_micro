/*

Quast module 

*/

process QUAST {
    tag "running Quast"
    publishDir "${params.outdir}/quast_out", mode: 'copy'

    conda "${moduleDir}/environment.yml"
    
    container "${ workflow.containerEngine == 'singularity' ?
       "docker://staphb/quast:latest" :
       "staphb/quast:latest" }"

       input:
    //tuple val(sample_id) , path(consensus)
    path(fasta)
    //tuple val(sample_id), path(gff)

    output:
    path("quast_out/transposed_report.tsv")               , emit: tsv
    path("quast_out/report.tsv"),                     emit: report_csv
    path("quast_out/*.html") , optional: true , emit: html
    path("quast_out/*.tex") , optional: true , emit: tex
    path("quast_out/*.pdf")     , optional: true , emit: pdf
    path "versions.yml"                                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args      = task.ext.args   ?: ''
    prefix        = "quast_out"
    //def features  = gff             ?  "--features $gff" : ''
    //def reference = fasta           ?  "-r $fasta"       : ''
    """
    mkdir -p quast_out
    quast.py \\
        --output-dir quast_out \\
        --threads $task.cpus \\
        $args \\
        ${fasta}
    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quast: \$(quast.py --version 2>&1 | sed 's/^.*QUAST v//; s/ .*\$//')
    END_VERSIONS
    """
}
