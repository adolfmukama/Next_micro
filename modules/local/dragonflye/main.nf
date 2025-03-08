/*

Dragonflye process

*/

process DRAGONFLYE {
    tag "running dragonflye"

    conda "bioconda::dragonflye"

    publishDir "${params.outdir}/dragonflye", mode: 'copy'

    input:
    tuple val(sample_id), path(read1), path(read2), path(longread)

    output:
    tuple val(sample_id), path('*.fa'), emit: scaffolds
    tuple val(sample_id), path('*.assembly.gfa.gz'), emit: gfa
    tuple val(sample_id), path('*.log')            , emit: log
    

    script:
    
    """
    conda run -n dragonflye dragonflye --R1 ${read1} \
    --R2 ${read2} \
    --reads ${longread} \
    --gsize 550000 \
    --trim \
    --cpus 32 \
    --outdir ./

    mv contigs.fa ${sample_id}.fa
    mv contigs.gfa ${sample_id}.assembly.gfa
    gzip -n ${sample_id}.assembly.gfa
    mv dragonflye.log ${sample_id}.dragonflye.log

   
    """
}