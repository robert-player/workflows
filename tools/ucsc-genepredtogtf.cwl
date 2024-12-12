cwlVersion: v1.0
class: CommandLineTool


hints:
- class: DockerRequirement
  dockerPull: biowardrobe2/ucscuserapps:v358_2


requirements:
- class: InlineJavascriptRequirement
  expressionLib:
  - var default_output_filename = function() {
          if (inputs.output_filename == ""){
            var root = inputs.annotation_tsv_file.basename.split('.').slice(0,-1).join('.');
            return (root == "")?inputs.annotation_tsv_file.basename+".gtf":root+".gtf";
          } else {
            return inputs.output_filename;
          }
        };


inputs:

  script:
    type: string?
    default: |
      #!/bin/bash
      TSV_FILE=$0
      GTF_FILE=$1
      cut -f 2- $TSV_FILE | grep -v "exonCount" | genePredToGtf file stdin $GTF_FILE
    inputBinding:
      position: 5
    doc: |
      Bash function to run cut -f 2- in.gp | genePredToGtf file stdin out.gp

  annotation_tsv_file:
    type: File
    inputBinding:
      position: 6
    doc: "TSV annotation file from UCSC Genome Browser"

  output_filename:
    type: string?
    default: ""
    inputBinding:
      valueFrom: $(default_output_filename())
      position: 7
    doc: "Output file name"


outputs:

  error_msg:
    type: File?
    outputBinding:
      glob: "error_msg.txt"

  error_report:
    type: File?
    outputBinding:
      glob: "error_report.txt"

  annotation_gtf_file:
    type: File
    outputBinding:
      glob: $(default_output_filename())
    doc: "GTF annotation file"


baseCommand: ["bash", "-c"]
stdout: error_msg.txt
stderr: error_msg.txt


label: "ucsc-genepredtogtf"
doc: |
  genePredToGtf - Convert genePred table or file to gtf

  usage:
    genePredToGtf database genePredTable output.gtf
  
  If database is 'file' then track is interpreted as a file
  rather than a table in database.
  options:
    -utr - Add 5UTR and 3UTR features
    -honorCdsStat - use cdsStartStat/cdsEndStat when defining start/end
      codon records
    -source=src set source name to use
    -addComments - Add comments before each set of transcript records.
      allows for easier visual inspection
  Note: use a refFlat table or extended genePred table or file to include
  the gene_name attribute in the output.  This will not work with a refFlat
  table dump file. If you are using a genePred file that starts with a numeric
  bin column, drop it using the UNIX cut command:
      cut -f 2- in.gp | genePredToGtf file stdin out.gp