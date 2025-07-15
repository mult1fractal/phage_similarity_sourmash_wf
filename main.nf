#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
* Nextflow -- phage similarity Pipeline 
* Author: mqt % jdzl
*/

/************************** 
* HELP messages & checks
**************************/

//header()

/* 
Nextflow version check  
Format is this: XX.YY.ZZ  (e.g. 20.07.1)
change below
*/

XX = "21"
YY = "04"
ZZ = "0"

if ( nextflow.version.toString().tokenize('.')[0].toInteger() < XX.toInteger() ) {
println "\033[0;33mgenome_to_json requires at least Nextflow version " + XX + "." + YY + "." + ZZ + " -- You are using version $nextflow.version\u001B[0m"
exit 1
}
else if ( nextflow.version.toString().tokenize('.')[1].toInteger() == XX.toInteger() && nextflow.version.toString().tokenize('.')[1].toInteger() < YY.toInteger() ) {
println "\033[0;33mgenome_to_json requires at least Nextflow version " + XX + "." + YY + "." + ZZ + " -- You are using version $nextflow.version\u001B[0m"
exit 1
}


// Log infos based on user inputs
if ( params.help ) { exit 0, helpMSG() }


// profile helps
if (params.profile) { exit 1, "--profile is WRONG use -profile" }


/************************** 
* INPUT
**************************/

// csv input 
// fasta input 
        if ( params.fasta ) { 
            fasta_raw_ch = Channel.fromPath( params.fasta, checkIfExists: true)
            .map { it -> tuple(it.baseName, it) } }
        else { fasta_raw_ch = Channel.empty() }



/************************** 
* include Workflows
**************************/
include {phage_tax_classification_wf} from './workflows/sourmash_wf/phage_tax_classification_wf.nf'




/************************** 
* MAIN WORKFLOW
**************************/
workflow {
phage_tax_classification_wf(fasta_raw_ch)
}


/*************  
* --help
*************/

def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    ____________________________________________________________________________________________
    


    ${c_yellow}Usage example:${c_reset}
    nextflow run main.nf --fasta '*.fasta' -profile local,docker --ncbi_db --output test
    nextflow run main.nf --fasta '*.fasta' -profile local,docker --phagescope_db --output test

    
    ${c_yellow}Options (optional)${c_reset}
    
     --cores                Amount of cores for a process (local use) [default: $params.cores]
     --max_cores            Max amount of cores for poreCov to use (local use) [default: $params.max_cores]
     --memory               Available memory [default: $params.memory]
     --output               Name of the result folder [default: $params.output]
     --workdir              Defines the path to the temporary files [default: $params.workdir]
     

   
    """.stripIndent()
}

/************************** 
* Log-infos
**************************/

def defaultMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    MPOA
    \u001B[1;30m______________________________________\033[0m

    \u001B[36mTaxonomic_classification of Phages\033[0m
    \u001B[1;30m______________________________________\033[0m
    Profile:                $workflow.profile
    Current User:           $workflow.userName
    Nextflow-version:       $nextflow.version
    Starting time:          $nextflow.timestamp

        --workdir           $params.workdir
        --output            $params.output
        --max_cores         $params.max_cores        
        --cores             $params.cores
        --mem               $params.memory
    \u001B[1;30m______________________________________\033[0m
    """.stripIndent()
}