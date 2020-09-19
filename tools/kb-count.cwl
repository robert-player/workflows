cwlVersion: v1.0
class: CommandLineTool


hints:
  - class: DockerRequirement
    dockerPull: biowardrobe2/kb-python:v0.0.2


inputs:

  fastq_file_1:
    type: File
    inputBinding:
      position: 100
    doc: |
      Fastq file 1

  fastq_file_2:
    type: File
    inputBinding:
      position: 101
    doc: |
      Fastq file 2
  
  fastq_file_3:
    type: File?
    inputBinding:
      position: 102
    doc: |
      Fastq file 3

  kallisto_index_file:
    type: File
    inputBinding:
      position: 5
      prefix: "-i"
    doc: |
      Kallisto index file

  tx_to_gene_mapping_file:
    type: File
    inputBinding:
      position: 6
      prefix: "-g"
    doc: |
      Transcript-to-gene mapping TSV file

  sc_technology:
    type:
    - type: enum
      name: "sc_technology"
      symbols:
      - 10XV1       # 3 input files
      - 10XV2       # 2 input files 
      - 10XV3       # 2 input files 
      - CELSEQ      # 2 input files
      - CELSEQ2     # 2 input files
      - DROPSEQ     # 2 input files
      - INDROPSV1   # 2 input files
      - INDROPSV2   # 2 input files
      - INDROPSV3   # 3 input files
      - SCRUBSEQ    # 2 input files
      - SURECELL    # 2 input files
    inputBinding:
      position: 7
      prefix: "-x"
    doc: "Single-cell technology used"

  workflow_type:
    type:
    - "null"
    - type: enum
      name: "workflow_type"
      symbols:
      - standard
      - lamanno
      - nucleus
      - kite
    inputBinding:
      position: 8
      prefix: "--workflow"
    doc: |
      Type of workflow. Use lamanno to calculate RNA velocity based
      on La Manno et al. 2018 logic. Use nucleus to calculate RNA
      velocity on single-nucleus RNA-seq reads.
      Default: standard

  tx_to_capture_mapping_file:
    type: File?
    inputBinding:
      position: 9
      prefix: "-c1"
    doc: |
      Transcripts-to-capture mapping TSV file

  intron_tx_to_capture_mapping_file:
    type: File?
    inputBinding:
      position: 10
      prefix: "-c2"
    doc: |
      Intron transcripts-to-capture mapping TSV file

  threads:
    type: int?
    inputBinding:
      position: 11
      prefix: "-t"
    doc: |
      Number of threads to use
      Default: 8

  memory_limit:
    type: string?
    inputBinding:
      position: 12
      prefix: "-m"
    doc: |
      Maximum memory used
      Default: 4G


outputs:

  counts_unfiltered_folder:
    type: Directory
    outputBinding:
      glob: "counts_unfiltered"
    doc: |
      Count matrix files generated by bustools count command

  whitelist_file:
    type: File
    outputBinding:
      glob: "*_whitelist.txt"
    doc: |
      File of whitelisted barcodes. Corresponds to the used
      single-cell technology

  bustools_inspect_report:
    type: File
    outputBinding:
      glob: "inspect.json"
    doc: |
      Report summarizing the contents of a sorted BUS file.
      Result of running bustools sort with not_sorted_bus_file,
      then bustools inspect with sorted BUS file

  kallisto_bus_report:
    type: File
    outputBinding:
      glob: "run_info.json"
    doc: |
      Report generated by kallisto bus run

  ec_mapping_file:
    type: File
    outputBinding:
      glob: "matrix.ec"
    doc: |
      File for mapping equivalence classes to transcripts.
      Direct output of kallisto bus command

  transcripts_file:
    type: File
    outputBinding:
      glob: "transcripts.txt"
    doc: |
      File to store transcript names.
      Direct output of kallisto bus command

  not_sorted_bus_file:
    type: File
    outputBinding:
      glob: "output.bus"
    doc: |
      Not sorted BUS file.
      Direct output of kallisto bus command

  corrected_sorted_bus_file:
    type: File
    outputBinding:
      glob: "output.unfiltered.bus"
    doc: |
      Sorted BUS file with corrected barcodes.
      Result of running bustools sort with
      not_sorted_bus_file, then bustools correct
      using whitelist_file and bustools sort with
      corrected BUS file


baseCommand: ["kb", "count", "--verbose"]


$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html

s:name: "kb-count"
s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows/master/tools/kb-count.cwl
s:codeRepository: https://github.com/Barski-lab/workflows
s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "Cincinnati Children's Hospital Medical Center"
  s:location:
  - class: s:PostalAddress
    s:addressCountry: "USA"
    s:addressLocality: "Cincinnati"
    s:addressRegion: "OH"
    s:postalCode: "45229"
    s:streetAddress: "3333 Burnet Ave"
    s:telephone: "+1(513)636-4200"
  s:logo: "https://www.cincinnatichildrens.org/-/media/cincinnati%20childrens/global%20shared/childrens-logo-new.png"
  s:department:
  - class: s:Organization
    s:legalName: "Allergy and Immunology"
    s:department:
    - class: s:Organization
      s:legalName: "Barski Research Lab"
      s:member:
      - class: s:Person
        s:name: Michael Kotliar
        s:email: mailto:misha.kotliar@gmail.com
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898


doc: |
  Uses kallisto to pseudoalign reads and bustools to quantify the data.

  1. Generates BUS file from input fastq files
  2. Sorts generated BUS file
  3. Inspects sorted BUS file
  4. Corrects barcodes in sorted BUS file
  5. Sorts corrected BUS file
  6. Generates count matrix from sorted barcode corrected BUS file

  Notes:
  --verbose was hardcoded
  --keep-tmp, --overwrite doesn't make sense when running from container
  -o is used by default, so all outputs go to the current folder

  Not implemented parameters:
  -w
  --tcc
  --dry-run
  --filter
  --loom
  --h5ad

s:about: |
  usage: kb count [-h] [--workflow {standard,lamanno,nucleus,kite}] [--keep-tmp] [--verbose] -i INDEX -g T2G -x TECHNOLOGY [-o OUT] [-w WHITELIST] [-t THREADS] [-m MEMORY] [--tcc]
                  [-c1 T2C] [-c2 T2C] [--overwrite] [--dry-run] [--lamanno | --nucleus] [--filter [{bustools}]] [--loom | --h5ad]
                  fastqs [fastqs ...]

  Generate count matrices from a set of single-cell FASTQ files. Run `kb --list` to view single-cell technology information.

  positional arguments:
    fastqs                FASTQ files

  optional arguments:
    -h, --help            Show this help message and exit
    --workflow {standard,lamanno,nucleus,kite}
                          Type of workflow. Use `lamanno` to calculate RNA velocity based on La Manno et al. 2018 logic. Use `nucleus` to calculate RNA velocity on single-nucleus
                          RNA-seq reads (default: standard)
    --keep-tmp            Do not delete the tmp directory
    --verbose             Print debugging information
    -o OUT                Path to output directory (default: current directory)
    -w WHITELIST          Path to file of whitelisted barcodes to correct to. If not provided and bustools supports the technology, a pre-packaged whitelist is used. If not, the
                          bustools whitelist command is used. (`kb --list` to view whitelists)
    -t THREADS            Number of threads to use (default: 8)
    -m MEMORY             Maximum memory used (default: 4G)
    --tcc                 Generate a TCC matrix instead of a gene count matrix.
    --overwrite           Overwrite existing output.bus file
    --dry-run             Dry run
    --lamanno             Deprecated. Use `--workflow lamanno` instead.
    --nucleus             Deprecated. Use `--workflow nucleus` instead.
    --filter [{bustools}]
                          Produce a filtered gene count matrix (default: bustools)
    --loom                Generate loom file from count matrix
    --h5ad                Generate h5ad file from count matrix

  required arguments:
    -i INDEX              Path to kallisto index
    -g T2G                Path to transcript-to-gene mapping
    -x TECHNOLOGY         Single-cell technology used (`kb --list` to view)

  required arguments for `lamanno` and `nucleus` workflows:
    -c1 T2C               Path to cDNA transcripts-to-capture
    -c2 T2C               Path to intron transcripts-to-captured