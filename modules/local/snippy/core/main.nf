process SNIPPY_CORE {
    tag "running snippy_core"
    publishDir "${params.outdir}/core_out", mode: 'copy'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/snippy:4.6.0--hdfd78af_2':
        'biocontainers/snippy:4.6.0--hdfd78af_1' }"

    input:
    path(vcf)
    path(aligned_fa)
    path reference

    output:
    path("${prefix}.aln")     , emit: aln
    path("${prefix}.full.aln"), emit: full_aln
    path("${prefix}.tab")     , emit: tab
    path("${prefix}.vcf")     , emit: vcf
    path("${prefix}.txt")     , emit: txt
    path "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "core_run"
    def is_compressed = reference.getName().endsWith(".gz") ? true : false
    def reference_name = reference.getName().replace(".gz", "")
    """
    if [ "$is_compressed" == "true" ]; then
        gzip -c -d $reference > $reference_name
    fi

    # Collect samples into necessary folders
    mkdir samples
    find . -name "*.vcf" | sed 's/\\.vcf\$//' | xargs -I {} bash -c 'mkdir samples/{}'
    find . -name "*.vcf" | sed 's/\\.vcf\$//' | xargs -I {} bash -c 'cp -L {}.vcf samples/{}/{}.vcf'
    find . -name "*.aligned.fa" | sed 's/\\.aligned.fa\$//' | xargs -I {} bash -c 'cp -L {}.aligned.fa samples/{}/{}.aligned.fa'

    # Run snippy-core
    snippy-core \\
        $args \\
        --ref $reference_name \\
        --prefix $prefix \\
        samples/*

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snippy-core: \$(echo \$(snippy-core --version 2>&1) | sed 's/snippy-core //')
    END_VERSIONS
    
    """
    
    
}