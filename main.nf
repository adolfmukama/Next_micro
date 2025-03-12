include { samplesheetToList } from 'plugin/nf-schema'
include { UNICYCLER } from './modules/local/unicycler/main.nf'
include { DRAGONFLYE } from './modules/local/dragonflye/main.nf'
include { FASTQC } from './modules/local/fastqc/main.nf'
include { MULTIQC } from './modules/local/multiqc/main.nf'
include { FASTP } from './modules/local/fastp/main.nf'
include { MULTIQC as MULTIQC_02 } from './modules/local/multiqc/main.nf'

workflow {
    def input = file("${projectDir}/sample_sheet.csv", checkIfExists: true)
    def schema = file("${projectDir}/schema_input.json", checkIfExists: true)
    meta_ch = Channel.fromList(samplesheetToList(input, schema))

    fastqc_ch = FASTQC(meta_ch)

    multi_01 = MULTIQC(
    fastqc_ch
    .zip
    .map { sample , zips -> zips }  // Extract only HTML file paths
    .collect()
    )

    fastp_out = FASTP(meta_ch)

    multi_01.html.map { file -> 
        def new_name = "initial_${file.baseName}.${file.extension}"
        return file.parent.resolve(new_name)
    }
    
    MULTIQC_02(
    fastp_out
    .json
    .collect()
    .flatMap {it}
    .map { file -> 
        def new_name = file.parent.resolve("filt_${file.name}")
        file.renameTo(new_name) ? new_name : file // Ensure renaming happens
    }
    )

    // UNICYCLER(meta_ch)
    // DRAGONFLYE(meta_ch)
}