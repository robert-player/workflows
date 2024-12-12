cwlVersion: v1.0
class: CommandLineTool


requirements:
  - class: ResourceRequirement
    ramMin: 15250
    coresMin: 4
  - class: InlineJavascriptRequirement


hints:
- class: DockerRequirement
  dockerPull: biowardrobe2/plugin-plot-rna:v0.0.4


inputs:

  annotation_file:
    type: File
    inputBinding:
      position: 5
      prefix: "--annotation"
    doc: |
      Path to the annotation TSV/CSV file

  bambai_pair:
    type: File
    inputBinding:
      position: 6
      prefix: "--bam"
    secondaryFiles:
    - .bai
    doc: |
      Path to the indexed BAM file

  isoforms_file:
    type: File
    inputBinding:
      position: 7
      prefix: "--isoforms"
    doc: |
      Path to the isoforms TSV/CSV file

  mapped_reads_number:
    type: int
    inputBinding:
      position: 8
      prefix: "--mapped"
    doc: |
      Mapped reads number

  output_prefix:
    type: string?
    inputBinding:
      position: 9
      prefix: "--output"
    doc: |
      Output prefix. Default: ./coverage

  pair:
    type: boolean?
    inputBinding:
      position: 10
      prefix: "--pair"
    doc: |
      Run as paired end. Default: false

  strand_specificity:
    type:
    - "null"
    - type: enum
      symbols:
      - "yes"
      - "no"
      - "reverse"
    inputBinding:
      position: 11
      prefix: "--stranded"      
    doc: |
      Whether the data is from a strand-specific assay.
      --stranded no      - a read is considered overlapping with a feature regardless of whether
                           it is mapped to the same or the opposite strand as the feature.
      --stranded yes     - the read has to be mapped to the same strand as the feature.
      --stranded reverse - the read has to be mapped to the opposite strand than the feature.

  minimum_rpkm:
    type: float?
    inputBinding:
      position: 12
      prefix: "--minrpkm"
    doc: |
      Ignore isoforms with RPKM smaller than --minrpkm.
      Default: 10

  minimum_isoform_length:
    type: float?
    inputBinding:
      position: 13
      prefix: "--minlength"
    doc: |
      Ignore isoforms shorter than --minlength.
      Default: 1000

  threads:
    type: int?
    inputBinding:
      position: 14
      prefix: "--threads"
    doc: |
      Threads


outputs:

  error_msg:
    type: File?
    outputBinding:
      glob: "error_msg.txt"

  error_report:
    type: File?
    outputBinding:
      glob: "error_report.txt"

  gene_body_report_file:
    type: File?
    outputBinding:
      glob: "*gene_body_report.tsv"

  gene_body_plot_png:
    type: File?
    outputBinding:
      glob: "*gene_body_plot.png"

  gene_body_plot_pdf:
    type: File?
    outputBinding:
      glob: "*gene_body_plot.pdf"

  rpkm_distribution_plot_png:
    type: File?
    outputBinding:
      glob: "*rpkm_distribution_plot.png"

  rpkm_distribution_plot_pdf:
    type: File?
    outputBinding:
      glob: "*rpkm_distribution_plot.pdf"


baseCommand: ["plot_rna.R"]
stdout: error_msg.txt
stderr: error_msg.txt


label: "plugin-plot-rna"
doc: |
  Runs R script to produce gene body average tag density plot and RPKM distribution histogram
  Doesn't fail even when we couldn't produce any plots

  usage: plugin_plot_rna.R
        [-h] --annotation ANNOTATION --bam BAM --isoforms ISOFORMS
        [--minrpkm MINRPKM] [--minlength MINLENGTH] --mapped MAPPED [--pair]
        [--stranded {yes,no,reverse}] [--output OUTPUT] [--threads THREADS]

  Gene body average tag density plot and RPKM distribution histogram for
  isoforms

  optional arguments:
    -h, --help            show this help message and exit
    --annotation ANNOTATION
                          Path to the annotation TSV/CSV file with gene names
                          set in name2 field
    --bam BAM             Path to the indexed BAM file
    --isoforms ISOFORMS   Path to the RPKM isoforms expression TSV/CSV file
    --minrpkm MINRPKM     Ignore isoforms with RPKM smaller than --minrpkm.
                          Default: 10
    --minlength MINLENGTH
                          Ignore isoforms shorter than --minlength. Default:
                          1000
    --mapped MAPPED       Mapped reads/pairs number
    --pair                Run as paired end. Default: false
    --stranded {yes,no,reverse}
                          Strand specificity. One of "yes", "no" or "reverse".
                          Default: "no"
    --output OUTPUT       Output prefix. Default: ./coverage
    --threads THREADS     Threads. Default: 1