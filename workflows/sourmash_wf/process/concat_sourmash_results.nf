process concat_sourmash_results {
      publishDir "${params.output}/${name}/final_results" 
      label 'ubuntu'
    //  errorStrategy 'ignore'
    input:
      tuple val(name), path(fasta)
      
    output:
      path("${name}_sourmash_result.csv")
    script:
      """
      touch ${name}_sourmash_result.csv
      for i in *.temporary; do
       tail -n+2 \$i >> ${name}_sourmash_result.csv
      done 
        sed -i 1i"similarity,md5,filename,name,query_filename,query_name,query_md5,ani" ${name}_sourmash_result.csv
      
      """
    stub:
        """
        touch ${name}.temporary
        """
}
