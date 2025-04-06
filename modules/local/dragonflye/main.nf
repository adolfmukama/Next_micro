/*

Dragonflye process

*/

process DRAGONFLYE {
    tag "running dragonflye"
    publishDir "${params.outdir}/dragonflye_out", mode: 'copy'
    errorStrategy 'ignore'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' ?
       "docker://community.wave.seqera.io/library/dragonflye:1.2.1--e91065815d0e1d03" :
       "community.wave.seqera.io/library/dragonflye:1.2.1--e91065815d0e1d03" }"

    input:
    tuple val(sample_id), path(read1), path(read2)
    path(longread, stageAs: "folder/*")

    output:
    tuple val(sample_id), path('*.fa'), emit: fasta
    tuple val(sample_id), path('*.assembly.gfa.gz'), emit: gfa
    tuple val(sample_id), path('*.log')            , emit: log, optional:true
    

    script:
    
    """
    mkdir lg_rd_dir
    mv ${longread} lg_rd_dir

    dragonflye --R1 ${read1} \
    --R2 ${read2} \
    --reads lg_rd_dir/${sample_id}* \
    --gsize 550000 \
    --trim \
    --cpus 32 \
    --outdir ./ \
    --force

    mv contigs.fa ${sample_id}.fa
    mv contigs.gfa ${sample_id}.assembly.gfa
    gzip -n ${sample_id}.assembly.gfa
    mv dragonflye.log ${sample_id}.dragonflye.log

   
    """
}