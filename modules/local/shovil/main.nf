/*

Shovill module 

*/

process SHOVILL {
    tag "running shovill"
    publishDir "${params.outdir}/shovill", mode: 'copy'

    conda "${moduleDir}/environment.yml"
    
    container "${ workflow.containerEngine == 'singularity' ?
       "docker://staphb/shovill:latest" :
       "staphb/shovill:latest" }"

    input:
    tuple val(sample_id), path(read1), path(read2)


    output:
    tuple val(sample_id), path("*.fa")                         , emit: contigs
    tuple val(sample_id), path("shovill.corrections")                , emit: corrections
    tuple val(sample_id), path("shovill.log")                        , emit: log
    tuple val(sample_id), path("{skesa,spades,megahit,velvet}.fasta"), emit: raw_contigs
    tuple val(sample_id), path("contigs.{fastg,gfa,LastGraph}")      , optional:true, emit: gfa
    path "versions.yml"                                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def memory = task.memory.toGiga()
    """
    shovill \\
        --R1 ${read1} \\
        --R2 ${read2} \\
        $args \\
        --cpus $task.cpus \\
        --ram $memory \\
        --outdir ./ \\
        --force

    mv contigs.fa ${sample_id}.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        shovill: \$(echo \$(shovill --version 2>&1) | sed 's/^.*shovill //')
    END_VERSIONS
    """
}