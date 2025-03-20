process IQTREE {
    tag 'running iqtree'
    publishDir "${params.outdir}/iqtree_out", mode: 'copy'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/iqtree:2.3.4--h21ec9f0_0' :
        'biocontainers/iqtree:2.3.4--h21ec9f0_0' }"

    input:
    path(alignment)
    

    output:
    path("*.treefile")      , emit: phylogeny     , optional: true
    path("*.iqtree")        , emit: report        , optional: true
    path("*.mldist")        , emit: mldist        , optional: true
    path("*.lmap.svg")      , emit: lmap_svg      , optional: true
    path("*.lmap.eps")      , emit: lmap_eps      , optional: true
    path("*.lmap.quartetlh"), emit: lmap_quartetlh, optional: true
    path("*.sitefreq")      , emit: sitefreq_out  , optional: true
    path("*.ufboot")        , emit: bootstrap     , optional: true
    path("*.state")         , emit: state         , optional: true
    path("*.contree")       , emit: contree       , optional: true
    path("*.nex")           , emit: nex           , optional: true
    path("*.splits")        , emit: splits        , optional: true
    path("*.suptree")       , emit: suptree       , optional: true
    path("*.alninfo")       , emit: alninfo       , optional: true
    path("*.partlh")        , emit: partlh        , optional: true
    path("*.siteprob")      , emit: siteprob      , optional: true
    path("*.sitelh")        , emit: sitelh        , optional: true
    path("*.treels")        , emit: treels        , optional: true
    path("*.rate  ")        , emit: rate          , optional: true
    path("*.mlrate")        , emit: mlrate        , optional: true
    path("GTRPMIX.nex")     , emit: exch_matrix   , optional: true
    path("*.log")           , emit: log
    path "versions.yml"                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args                        = task.ext.args           ?: ''
    def alignment_arg               = alignment               ? "-s $alignment"                 : ''
    /*def tree_arg                    = tree                    ? "-t $tree"                      : ''
    def tree_te_arg                 = tree_te                 ? "-te $tree_te"                  : ''
    def lmclust_arg                 = lmclust                 ? "-lmclust $lmclust"             : ''
    def mdef_arg                    = mdef                    ? "-mdef $mdef"                   : ''
    def partitions_equal_arg        = partitions_equal        ? "-q $partitions_equal"          : ''
    def partitions_proportional_arg = partitions_proportional ? "-spp $partitions_proportional" : ''
    def partitions_unlinked_arg     = partitions_unlinked     ? "-sp $partitions_unlinked"      : ''
    def guide_tree_arg              = guide_tree              ? "-ft $guide_tree"               : ''
    def sitefreq_in_arg             = sitefreq_in             ? "-fs $sitefreq_in"              : ''
    def constraint_tree_arg         = constraint_tree         ? "-g $constraint_tree"           : ''
    def trees_z_arg                 = trees_z                 ? "-z $trees_z"                   : ''
    def suptree_arg                 = suptree                 ? "-sup $suptree"                 : ''
    def trees_rf_arg                = trees_rf                ? "-rf $trees_rf"                 : '' */
    def prefix                      = task.ext.prefix         ?: "iq_tree" 
    def memory                      = task.memory.toString().replaceAll(' ', '')
    """
    iqtree \\
        $args \\
        $alignment_arg \\
        -pre $prefix \\
        -nt AUTO \\
        -ntmax $task.cpus \\
        -mem $memory \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        iqtree: \$(echo \$(iqtree -version 2>&1) | sed 's/^IQ-TREE multicore version //;s/ .*//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "iq_tree"
    """
    touch "${prefix}.treefile"
    touch "${prefix}.iqtree"
    touch "${prefix}.mldist"
    touch "${prefix}.lmap.svg"
    touch "${prefix}.lmap.eps"
    touch "${prefix}.lmap.quartetlh"
    touch "${prefix}.sitefreq"
    touch "${prefix}.ufboot"
    touch "${prefix}.state"
    touch "${prefix}.contree"
    touch "${prefix}.nex"
    touch "${prefix}.splits"
    touch "${prefix}.suptree"
    touch "${prefix}.alninfo"
    touch "${prefix}.partlh"
    touch "${prefix}.siteprob"
    touch "${prefix}.sitelh"
    touch "${prefix}.treels"
    touch "${prefix}.rate"
    touch "${prefix}.mlrate"
    touch "GTRPMIX.nex"
    touch "${prefix}.log"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        iqtree: \$(echo \$(iqtree -version 2>&1) | sed 's/^IQ-TREE multicore version //;s/ .*//')
    END_VERSIONS
    """
/*
iqtree \\
        $args \\
        $alignment_arg \\
        $tree_arg \\
        $tree_te_arg \\
        $lmclust_arg \\
        $mdef_arg \\
        $partitions_equal_arg \\
        $partitions_proportional_arg \\
        $partitions_unlinked_arg \\
        $guide_tree_arg \\
        $sitefreq_in_arg \\
        $constraint_tree_arg \\
        $trees_z_arg \\
        $suptree_arg \\
        $trees_rf\\
        -pre $prefix \\
        -nt AUTO \\
        -ntmax $task.cpus \\
        -mem $memory \\
        */
}