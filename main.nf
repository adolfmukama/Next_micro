include { samplesheetToList } from 'plugin/nf-schema' 
include { UNICYCLER } from './modules/local/unicycler/main.nf' 
include { DRAGONFLYE } from './modules/local/dragonflye/main.nf' 
include { FASTQC } from './modules/local/fastqc/main.nf' 
include { MULTIQC } from './modules/local/multiqc/main.nf' 
include { FASTP } from './modules/local/fastp/main.nf' 
include { MULTIQC as MULTIQC_02 } from './modules/local/multiqc/main.nf' 
include { SHOVILL } from './modules/local/shovil/main.nf' 
include { QUAST } from './modules/local/quast/main.nf'  
include { CHECKM2_DATABASEDOWNLOAD } from './modules/local/checkm2/db_download/main.nf'
include { CHECKM2 } from './modules/local/checkm2/predict/main.nf'
include { PROKKA } from './modules/local/prokka/main.nf'
workflow {     
    def input = file("${projectDir}/sample_sheet.csv", checkIfExists: true)     
    def schema = file("${projectDir}/schema_input.json", checkIfExists: true)     
    meta_ch = Channel.fromList(samplesheetToList(input, schema))      
    
    fastqc_ch = FASTQC(meta_ch)      
    MULTIQC(     
        fastqc_ch         
        .zip         
        .map { sample, zips -> zips }  // Extract only zip files         
        .collect() )           
        
    fastp_out = FASTP(meta_ch)

    MULTIQC_02(     
        fastp_out         
        .json         
        .collect()     
        )       
    
    shov_ch = SHOVILL(         
        fastp_out.reads     
        )      
        
    quast_ch = QUAST(     
        shov_ch         
        .contigs         
        .map { sample, cont -> cont }  // Extract only contig files         
        .collect() )   

    db = CHECKM2_DATABASEDOWNLOAD(params.db_zenodo_id) 

    CHECKM2 (
        shov_ch         
        .contigs         
        .map { sample, cont -> cont }  // Extract only contig files         
        .collect(),
        db.database

    ) 

    PROKKA(
        shov_ch
        .contigs
    )     
        
    // UNICYCLER(meta_ch)     // DRAGONFLYE(meta_ch) 
    
    }

