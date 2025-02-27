include { samplesheetToList } from 'plugin/nf-schema'
include { UNICYCLER } from './modules/local/unicycler/main.nf'
include { DRAGONFLYE } from './modules/local/dragonflye/main.nf'
workflow {
    def input = file("${projectDir}/sample_sheet.csv", checkIfExists: true)
    def schema = file("${projectDir}/schema_input.json", checkIfExists: true)
    meta_ch = Channel.fromList(samplesheetToList(input, schema)).view()


    UNICYCLER(meta_ch)
    DRAGONFLYE(meta_ch)
}