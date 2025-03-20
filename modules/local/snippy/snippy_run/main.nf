process SNIPPY_RUN {
    tag "running snippy"
    publishDir "${params.outdir}/snippy_out", mode: 'copy'
    //errorStrategy 'ignore'

    conda "${moduleDir}/environment.yml"
    
    container "${ workflow.containerEngine == 'singularity' ?
       "docker://nanozoo/snippy:4.6.0--2f6637b" :
       "nanozoo/snippy:4.6.0--2f6637b" }"

    input:
    tuple val(sample_id), path(read1), path(read2), path(longread)
    val reference

    output:
    tuple val(sample_id), path("${sample_id}/${sample_id}.tab")              , emit: tab
    tuple val(sample_id), path("${sample_id}/${sample_id}.csv")              , emit: csv
    tuple val(sample_id), path("${sample_id}/${sample_id}.html")             , emit: html
    tuple val(sample_id), path("${sample_id}/${sample_id}.vcf")              , emit: vcf
    tuple val(sample_id), path("${sample_id}/${sample_id}.bed")              , emit: bed
    tuple val(sample_id), path("${sample_id}/${sample_id}.gff")              , emit: gff
    tuple val(sample_id), path("${sample_id}/${sample_id}.bam")              , emit: bam
    tuple val(sample_id), path("${sample_id}/${sample_id}.bam.bai")          , emit: bai
    tuple val(sample_id), path("${sample_id}/${sample_id}.log")              , emit: log
    tuple val(sample_id), path("${sample_id}/${sample_id}.aligned.fa")       , emit: aligned_fa
    tuple val(sample_id), path("${sample_id}/${sample_id}.consensus.fa")     , emit: consensus_fa
    tuple val(sample_id), path("${sample_id}/${sample_id}.consensus.subs.fa"), emit: consensus_subs_fa
    tuple val(sample_id), path("${sample_id}/${sample_id}.raw.vcf")          , emit: raw_vcf
    tuple val(sample_id), path("${sample_id}/${sample_id}.filt.vcf")         , emit: filt_vcf
    tuple val(sample_id), path("${sample_id}/${sample_id}.vcf.gz")           , emit: vcf_gz
    tuple val(sample_id), path("${sample_id}/${sample_id}.vcf.gz.csi")       , emit: vcf_csi
    tuple val(sample_id), path("${sample_id}/${sample_id}.txt")              , emit: txt
    path "versions.yml"                                        , emit: versions
    

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "snippy-out"
    def read_inputs = "--R1 ${read1} --R2 ${read2}"
    def id = file(sample_id.toString()).baseName.replaceAll(/\.fa$/, '')
    //echo "DEBUG: Sample ID = ${id}"

    """
    ID=\$(echo $id)
    snippy \\
        $args \\
        --cpus $task.cpus \\
        --ram $task.memory \\
        --outdir ${sample_id} \\
        --reference $reference \\
        --prefix \$ID \\
        --force \\
        $read_inputs

    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snippy: \$(echo \$(snippy --version 2>&1) | sed 's/snippy //')
    END_VERSIONS
    """
}

