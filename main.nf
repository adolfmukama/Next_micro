include { samplesheetToList } from 'plugin/nf-schema' 
include { UNICYCLER } from './modules/local/unicycler/main.nf' 
include { DRAGONFLYE } from './modules/local/dragonflye/main.nf' 
include { FASTQC } from './modules/local/fastqc/main.nf' 
include { MULTIQC } from './modules/local/multiqc/main.nf' 
include { FASTP } from './modules/local/fastp/main.nf'
include { FILTLONG } from './modules/local/filtlong/main.nf' 
include { MULTIQC as MULTIQC_02 } from './modules/local/multiqc/main.nf' 
include { SHOVILL } from './modules/local/shovil/main.nf' 
include { QUAST } from './modules/local/quast/main.nf'  
include { CHECKM2_DATABASEDOWNLOAD } from './modules/local/checkm2/db_download/main.nf'
include { CHECKM2 } from './modules/local/checkm2/predict/main.nf'
include { PROKKA } from './modules/local/prokka/main.nf'
include { PANAROO_RUN } from './modules/local/panaroo/main.nf'
include { SNIPPY_RUN } from './modules/local/snippy/snippy_run/main.nf'
include { SNIPPY_MAP } from './modules/local/snippy/snippy_map/main.nf'
include { QUALIMAP_BAMQC } from './modules/local/qualimap/main.nf'
include { SNIPPY_CORE } from './modules/local/snippy/core/main.nf'
include { GUBBINS } from './modules/local/gubbins/main.nf'
include { SNPSITES } from './modules/local/snp-sites/main.nf'
include { SNPDISTS } from './modules/local/snp-dist/main.nf'
include { IQTREE } from './modules/local/iqtree/main.nf'


workflow {     
    def input    = file("${projectDir}/sample_sheet.csv", checkIfExists: true)     
    def schema   = file("${projectDir}/schema_input.json", checkIfExists: true)     
    meta_ch      = Channel.fromList(samplesheetToList(input, schema))      
    ref_ch       = Channel.value(params.reference)
    
    fastqc_ch = FASTQC(meta_ch)      
    
    
    MULTIQC(     
        fastqc_ch         
        .zip                  
        .collect()
        
        )           
        
    fastp_out = FASTP(meta_ch)

    filtlong_out = FILTLONG(meta_ch)

    MULTIQC_02(     
        fastp_out         
        .json         
        .collect()    
        )       
    /*
    shov_ch = SHOVILL(         
        fastp_out.reads     
        )      
        
    quast_ch = QUAST(     
        shov_ch         
        .contigs         
        .map { sample, cont -> cont }  // Extract only contig files         
        .collect()
        )   

    db = CHECKM2_DATABASEDOWNLOAD(params.db_zenodo_id) 

    CHECKM2 (
        shov_ch         
        .contigs         
        .map { sample, cont -> cont }  // Extract only contig files         
        .collect(),
        db.database 

    ) 

    prokka_ch = PROKKA(
                    shov_ch
                    .contigs
                )  

    PANAROO_RUN(
        prokka_ch         
        .gff         
        .map { sample, gff -> gff }  // Extract only contig files         
        .collect() 
        .view()  

    )

    snippy_out = SNIPPY_RUN (
                    meta_ch,
                    ref_ch

                ) */

    
    /*
    core_ch = SNIPPY_CORE(
    snippy_out
        .vcf
        .map { sample, vcf -> vcf }  // Extracts only VCF file paths
        .collect(),  // Collects all VCF files into a list

    snippy_out
        .aligned_fa
        .map { sample, fa -> fa }  // Extracts only aligned.fa file paths
        .collect(),  // Collects all aligned.fa files into a list

    ref_ch
)
   gubbins_ch = GUBBINS (
        core_ch
        .aln
    ) 

    snp_site_ch = SNPSITES (
        core_ch
        .aln
    )  
    snp_dist_ch = SNPDISTS (
        snp_site_ch
        .fasta
    )
    IQTREE(
        snp_site_ch
        .fasta
        ) 

    //PLASMIDFINDER(
        
    //) */

    unicycler_out = UNICYCLER(
        fastp_out.reads,
        filtlong_out.
        reads.
        map {sample_id, file -> file}.
        collect()
        )     
    
    DRAGONFLYE(fastp_out.reads,
        filtlong_out.
        reads.
        map {sample_id, file -> file}.
        collect()) 
    
    snippy_map = SNIPPY_MAP (
                    meta_ch,        
                    unicycler_out
                    .fasta         
                    .map { sample, cont -> cont }  // Extract only contig files         
                    .collect()

                )
    QUALIMAP_BAMQC(snippy_map
                    .bam,
                   snippy_map
                     .gff)

}

