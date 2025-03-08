/*

Unicycler process

*/

process UNICYCLER {
    tag "running unicycler"

    conda "bioconda::unicycler"

    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), path(read1), path(read2), path(longread)

    output:
    tuple val(sample_id), path('*.scaffolds.fa.gz'), emit: scaffolds
    tuple val(sample_id), path('*.assembly.gfa.gz'), emit: gfa
    tuple val(sample_id), path('*.log')            , emit: log
    

    script:
    
    """
    conda run -n unicycler unicycler -1 ${read1} \
    -2 ${read2} \
    -l ${longread} \
    -t 32 \
    -o ./

    mv assembly.fasta ${sample_id}.scaffolds.fa
    gzip -n ${sample_id}.scaffolds.fa
    mv assembly.gfa ${sample_id}.assembly.gfa
    gzip -n ${sample_id}.assembly.gfa
    mv unicycler.log ${sample_id}.unicycler.log

   
    """
}