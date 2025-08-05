include { sourmash_tax } from './process/sourmash_tax.nf'
include { split_multi_fasta_2 } from './process/split_multi_fasta.nf'
include { download_references_NCBI } from './process/download_tax_references'
include { download_references_phage_scope } from './process/download_tax_references'
include { sourmash_NCBI_tax_build } from './process/sourmash_tax_build_DB.nf'
include { sourmash_phage_scope_tax_build } from './process/sourmash_tax_build_DB.nf'
include { concat_sourmash_results } from './process/concat_sourmash_results.nf'

workflow phage_tax_classification_wf {
    take:   fasta
    main:    
            //fasta = fasta_and_tool_results.map {it -> tuple(it[0],it[1])}
            // get refs

                    if (params.ncbi_db) {
                         download_references_NCBI()
                         sourmash_NCBI_tax_build(download_references_NCBI.out.phage_ref_ch)
                         sourmash_tax_db_ch = sourmash_NCBI_tax_build.out.phage_db_ch
                         sourmash_tax_metadata_ch = download_references_NCBI.out.ncbi_tax_metadata_ch
                         }
                         
                    else if (params.phagescope_db) {
                         download_references_phage_scope()
                         sourmash_phage_scope_tax_build(download_references_phage_scope.out.phage_ref_ch)
                         sourmash_tax_db_ch = sourmash_phage_scope_tax_build.out.phage_db_ch 
                         sourmash_tax_metadata_ch = download_references_phage_scope.out.phagescope_tax_metadata_ch
                         }

           
                    
                    split_multi_fasta_2(fasta) 
                    //split_multi_fasta_2.out.view()
                    tax_input_ch =split_multi_fasta_2.out.transpose()  // [name, fasta] are string objetcts. so i cant rename via basename
                    renamed_ch = tax_input_ch.map { name, fasta_file ->
                                                       def new_name = "${fasta_file.baseName}"
                                                       tuple(name, fasta_file, new_name)
                                                       }
                                                                           
                                                                        
                    //renamed_ch.view()  
                    sourmash_tax(renamed_ch, sourmash_tax_db_ch).groupTuple(remainder: true)
                    
                    //collect files back into name, [list of *temporary filepath objects]
                    collect_results_ch = sourmash_tax.out.tax_class_ch.groupTuple()
                    //collect_results_ch.view()
                   // concat_sourmash_results(collect_results_ch)
                    
            
    emit:   sourmash_tax.out
}