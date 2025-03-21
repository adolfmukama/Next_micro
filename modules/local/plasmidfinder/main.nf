process PLASMIDFINDER {
    tag "running plasmidfinder"
    publishDir "${params.outdir}/snippy_out", mode: 'copy'

    // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/plasmidfinder:2.1.6--py310hdfd78af_1':
        'biocontainers/plasmidfinder:2.1.6--py310hdfd78af_1' }"

    input:
    tuple val(sample_id), path(seqs)

    output:
    tuple val(sample_id), path("*.json")                 , emit: json
    tuple val(sample_id), path("*.txt")                  , emit: txt
    tuple val(sample_id), path("*.tsv")                  , emit: tsv
    tuple val(sample_id), path("*-hit_in_genome_seq.fsa"), emit: genome_seq
    tuple val(sample_id), path("*-plasmid_seqs.fsa")     , emit: plasmid_seq
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${sample_id}"
    def VERSION = '2.1.6' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    plasmidfinder.py \\
        $args \\
        -i $seqs \\
        -o ./ \\
        -x

    # Rename hard-coded outputs with prefix to avoid name collisions
    mv data.json ${prefix}.json
    mv results.txt ${prefix}.txt
    mv results_tab.tsv ${prefix}.tsv
    mv Hit_in_genome_seq.fsa ${prefix}-hit_in_genome_seq.fsa
    mv Plasmid_seqs.fsa ${prefix}-plasmid_seqs.fsa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        plasmidfinder: $VERSION
    END_VERSIONS
    """
}