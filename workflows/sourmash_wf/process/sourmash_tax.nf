process sourmash_tax {
      storeDir "${params.output}/${name}/taxonomic-classification/${new_name}" 
      label 'sourmash'
    //  errorStrategy 'ignore'
    input:
      tuple val(name), path(fasta), val(new_name)
      file(database)
      
    output:
      tuple val(name), path("*.temporary"), emit: tax_class_ch optional true
    script:
      """
      easy_name=\$( basename ${fasta})
        sourmash sketch dna -p k=21,scaled=100 ${fasta}
    
        sourmash search -k 21 *.sig phages.sbt.zip -o  \$easy_name.temporary

      """
    stub:
        """
        touch ${name}.temporary
        """
}




//  for fastafile in ${fasta_dir}/*.fa; do
//         sourmash sketch dna -p k=21,scaled=100 \${fastafile}
//       done

//       for signature in *.sig; do
//         sourmash search -k 21 \${signature} phages.sbt.zip -o \${signature}.temporary
//       done
    



// touch ${name}_tax-class.tsv 

// for taxfile in *.temporary; do

                      
//         similarity_and_name=\$(if [ \$(wc -l < \$taxfile) == 0 ]
//                     then
//                       echo "0\tno match found"
//                     else 
//                         grep -v "similarity,md5,filename,name,query_filename,query_name,query_md5,ani" \$taxfile | sort -t',' -k1,1r |head -1 |  cut -d"," -f1,4 | tr ',' '\\t'
//                     fi )
                

//           filename=\$(basename \${taxfile} .fa.sig.temporary)
//           phage_tax_name=\$(echo "\$similarity_and_name" |cut -f2)
//           phagemetadata=\$(if [[ "\$similarity_and_name" == *"no match found" ]]
//                               then
//                                 echo "no match found\tno match found\tno match found"
//                               else          
//                                 grep "\$phage_tax_name" ${metadata} | cut -f4,6,7
//                               fi )
          

//         #printf "%s\\t%s\\t%s\\t%s\\n" "\$filename" "\$similarity_and_name" "\$phagemetadata" >> ${name}_tax-class.tsv
//         echo "\$filename\t\$similarity_and_name\t\$phagemetadata" >> ${name}_tax-class.tsv
//       done
//       sed -i 1i"Contig\\tSimilarity\\tPredicted_accession_number\\tTaxonomy\\tHost_of_Predicted_accession_number\\tLifestyle_of_Predicted_accession_number" ${name}_tax-class.tsv
