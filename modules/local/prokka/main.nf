process PROKKA {
    tag "running prokka"
    publishDir "${params.outdir}/prokka/${prefix}", mode: 'copy'

    conda "${moduleDir}/environment.yml"
    
    container "${ workflow.containerEngine == 'singularity' ?
       "docker:/staphb/prokka:latest" :
       "staphb/prokka:latest" }"

    input:
    tuple val(sample_id), path(fasta)
    

    output:
    tuple val(sample_id), path("${prefix}/*.gff"), emit: gff
    tuple val(sample_id), path("${prefix}/*.gbk"), emit: gbk
    tuple val(sample_id), path("${prefix}/*.fna"), emit: fna
    tuple val(sample_id), path("${prefix}/*.faa"), emit: faa
    tuple val(sample_id), path("${prefix}/*.ffn"), emit: ffn
    tuple val(sample_id), path("${prefix}/*.sqn"), emit: sqn
    tuple val(sample_id), path("${prefix}/*.fsa"), emit: fsa
    tuple val(sample_id), path("${prefix}/*.tbl"), emit: tbl
    tuple val(sample_id), path("${prefix}/*.err"), emit: err
    tuple val(sample_id), path("${prefix}/*.log"), emit: log
    tuple val(sample_id), path("${prefix}/*.txt"), emit: txt
    tuple val(sample_id), path("${prefix}/*.tsv"), emit: tsv
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when
    //prefix = task.ext.prefix ?: "${sample_id}".replaceAll(/\.fa$/, '')

     script:
    def args             = task.ext.args   ?: ''
    prefix = task.ext.prefix ?: file(sample_id).baseName.replaceAll(/\.fa$/, '')
    def input            = fasta.toString() - ~/\.gz$/
    def decompress       = fasta.getExtension() == "gz" ? "gunzip -c ${fasta} > ${input}" : ""
    def cleanup          = fasta.getExtension() == "gz" ? "rm ${input}" : ""
    //def proteins_opt     = proteins ? "--proteins ${proteins}" : ""
    //def prodigal_tf_in   = prodigal_tf ? "--prodigaltf ${prodigal_tf}" : ""
    """
    ${decompress}

    prokka \\
        ${args} \\
        --cpus ${task.cpus} \\
        --prefix ${prefix} \\
        ${input}

    ${cleanup}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prokka: \$(echo \$(prokka --version 2>&1) | sed 's/^.*prokka //')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${sample_id}".replaceAll(/\.fa$/, '')
    """
    mkdir ${prefix}
    touch ${prefix}/${prefix}.gff
    touch ${prefix}/${prefix}.gbk
    touch ${prefix}/${prefix}.fna
    touch ${prefix}/${prefix}.faa
    touch ${prefix}/${prefix}.ffn
    touch ${prefix}/${prefix}.sqn
    touch ${prefix}/${prefix}.fsa
    touch ${prefix}/${prefix}.tbl
    touch ${prefix}/${prefix}.err
    touch ${prefix}/${prefix}.log
    touch ${prefix}/${prefix}.txt
    touch ${prefix}/${prefix}.tsv
    touch ${prefix}/${prefix}.gff

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prokka: \$(echo \$(prokka --version 2>&1) | sed 's/^.*prokka //')
    END_VERSIONS
    """
}