/*

Unicycler process

*/

process UNICYCLER {
    tag "running unicycler"
    publishDir "${params.outdir}/unicycler_out", mode: 'symlink'
    errorStrategy 'ignore'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' ?
       "docker://community.wave.seqera.io/library/unicycler:0.5.1--b9d21c454db1e56b" :
       "community.wave.seqera.io/library/unicycler:0.5.1--b9d21c454db1e56b" }"

    input:
    tuple val(sample_id), path(read1), path(read2)
    path(longread, stageAs: "folder/*")

    output:
    tuple val(sample_id), path('*.fasta'), emit: fasta
    tuple val(sample_id), path('*.assembly.gfa.gz'), emit: gfa
    tuple val(sample_id), path('*.log')            , emit: log
    

    script:
    
    
    """
    mkdir lg_rd_dir
    mv ${longread} lg_rd_dir
    
    unicycler -1 ${read1} \
    -2 ${read2} \
    -l lg_rd_dir/${sample_id}* \
    -t 12 \
    -o ./

    mv assembly.fasta ${sample_id}.fasta
    mv assembly.gfa ${sample_id}.assembly.gfa
    gzip -n ${sample_id}.assembly.gfa
    mv unicycler.log ${sample_id}.unicycler.log

   
    """
}