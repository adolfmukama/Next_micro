include { samplesheetToList } from 'plugin/nf-schema'
include { UNICYCLER } from './modules/local/unicycler/main.nf'
include { DRAGONFLYE } from './modules/local/dragonflye/main.nf'
include { FASTQC } from './modules/local/fastqc/main.nf'
include { MULTIQC } from './modules/local/multiqc/main.nf'
workflow {
    def input = file("${projectDir}/sample_sheet.csv", checkIfExists: true)
    def schema = file("${projectDir}/schema_input.json", checkIfExists: true)
    meta_ch = Channel.fromList(samplesheetToList(input, schema))

    fastqc_ch = FASTQC(meta_ch)

    MULTIQC(
    fastqc_ch
    .zip
    .map { sample , htmls -> htmls }  // Extract only HTML file paths
    .collect()
    )
    // UNICYCLER(meta_ch)
    // DRAGONFLYE(meta_ch)
}