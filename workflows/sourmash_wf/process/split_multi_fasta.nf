process split_multi_fasta_2 {
      label 'seqkit'
    input:
      tuple val(name), path(fasta) 
    output:
      tuple val(name), path("*.split/*id_*.fasta") 
    script:
      """
      seqkit split --by-id ${fasta}
      #mv *split/* .
      #rm *.split
      #rm ${fasta}
      """
    stub:
      """
      touch ${name}.fasta
      """
}
// label 'seqkit'
// seqkit split --by-id ${fasta}

// nextflow run main.nf --multi_fasta /mnt/6tb_3/Phage-scope_database/fastas/all_NCBI-Refseq_phages_23-04-2025.fasta --ncbi_db -profile local,docker -work-dir /mnt/6tb_1/work/ --output results/multifasta_ncbi/ --databases /mnt/6tb_1/nextflow-autodownload-databases/ -resume

// label 'ubuntu'
// mkdir ${name}_contigs/

//       while read line
//         do
//       if [[ \${line:0:1} == '>' ]]
//       then
//         outfile=\${line#>}.fa
//         echo "\${line}" > ${name}_contigs/\${outfile}
//       else
//         echo "\${line}" >> ${name}_contigs/\${outfile}
//       fi
//         done < ${fasta}

    // stub:
    //   """
    //   mkdir ${name}_contigs/
    //   """