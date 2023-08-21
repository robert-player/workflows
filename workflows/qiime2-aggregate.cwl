cwlVersion: v1.0
class: Workflow


requirements:
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

'sd:serviceTag': "Analysis"

'sd:upstream':
  qiime2_sample_pe:
   - "qiime2-sample-pe.cwl"
   - "https://github.com/datirium/workflows/workflows/qiime2-sample-pe.cwl"


inputs:

  alias:
    type: string
    label: "Sample short name/Alias:"
    'sd:localLabel': true
    doc: |
      Short name for the analysis.
    sd:preview:
      position: 1

  metadata_file:
    type: File
    label: "Metadata file to assign experimental conditions to samples:"
    'sd:localLabel': true
    doc: |
      Path to the TSV file containing experiment metadata. The first column must have the header "sample-id" with sample names exactly as they have been input into your SciDAP project. The remaining column headers are experiment-specific. NOTE: Custom Label parameter metadata must be INT data type.
    sd:preview:
      position: 2

  pcoa_label:
    type: string
    label: "Metadata header name for PCoA axis label:"
    'sd:localLabel': true
    doc: |
      Must be identical to one of the headers of the metadata file. Values under this metadata header must be INT. Required for PCoA analysis.
    sd:preview:
      position: 3

  sampling_depth:
    type: int
    label: "Rarefaction normalization sampling depth:"
    'sd:localLabel': true
    doc: |
      Required for differential abundance analyses (along with group and taxonomic level). This step will subsample the counts in each sample without replacement so that each sample in the resulting table has a total count of INT. If the total count for any sample(s) are smaller than this value, those samples will be dropped from further analysis. It's recommend making your choice by reviewing the rarefaction plot. Choose a value that is as high as possible (so you retain more sequences per sample) while excluding as few samples as possible.
    sd:preview:
      position: 4

  diff_group:
    type: string
    label: "Metadata header name for differential abundance analyses:"
    'sd:localLabel': true
    doc: |
      Required for differential abundance analyses (along with sampling depth and taxonomic level). Group/experimental condition column name from sample metadata file. Must be identical to one of the headers of the sample-metadata file. The corresponding column should only have two groups/conditions.
    sd:preview:
      position: 5

  taxonomic_level:
    type:
    - "null"
    - type: enum
      symbols:
      - Kingdom
      - Phylum
      - Class
      - Order
      - Family
      - Genus
      - Species
    label: "Taxonomic level for differential abundance analysis:"
    'sd:localLabel': true
    doc: |
      Required for differential abundance analyses (along with sampling depth and group). Collapses the OTU table at the taxonomic level of interest for differential abundance analysis with ANCOM. Default: Genus
    sd:preview:
      position: 6

  fastq_r1_array:
    type:
    - File
    - type: array
    - items: File
    label: "Read 1 FASTQ files:"
    'sd:localLabel': true
    format: "http://edamontology.org/format_1930"
    doc: |
      Read 1 FASTQ file from a paired-end sequencing run.
    sd:preview:
      position: 11

  fastq_r2_array:
    type:
    - File
    - type: array
    - items: File
    label: "Read 2 FASTQ files:"
    'sd:localLabel': true
    format: "http://edamontology.org/format_1930"
    doc: |
      Read 2 FASTQ file that pairs with the input R1 file.
    sd:preview:
      position: 12

  trimLeftF:
    type: int?
    default: 0
    label: "Trim 5' of R1:"
    'sd:localLabel': true
    doc: |
      Should be the same value used for the samples being used as input. Recommended if adapters are still on the input sequences. Trims the first J bases from the 5' end of each forward read.

  trimLeftR:
    type: int?
    default: 0
    label: "Trim 5' of R2:"
    'sd:localLabel': true
    doc: |
      Should be the same value used for the samples being used as input. Recommended if adapters are still on the input sequences. Trims the first K bases from the 5' end of each reverse read.

  truncLenF:
    type: int
    default: 0
    label: "Truncate 3' of R1:"
    'sd:localLabel': true
    doc: |
      Should be the same value used for the samples being used as input. Clips the forward read starting M bases from the 5' end (before trimming). If base quality is OK for entire read, value should be set to the expected number of Illumina cycles for R1.

  truncLenR:
    type: int
    default: 0
    label: "Truncate 3' of R2:"
    'sd:localLabel': true
    doc: |
      Should be the same value used for the samples being used as input. Clips the reverse read starting N bases from the 5' end (before trimming).  If base quality is OK for entire read, value should be set to the expected number of Illumina cycles for R2.

  threads:
    type: int?
    default: 4
    label: "Threads:"
    'sd:localLabel': true
    doc: |
      Number of threads to use for steps that support multithreading.


outputs:

  overview:
    type: File
    format: "http://edamontology.org/format_3835"
    label: "summary of inputs"
    doc: "summary of inputs"
    outputSource: qiime_pipeline/overview
    'sd:visualPlugins':
    - markdownView:
        tab: 'Overview'

  fastq_summary:
    type: File
    label: "Summary of input FASTQ reads"
    doc: "summary of input read data"
    outputSource: qiime_pipeline/fastq_summary
    'sd:visualPlugins':
    - qiime2:
        tab: 'Overview'
        target: "_blank"

  denoising_stats:
    type: File
    label: "Summary of read data denoising"
    doc: "summary of read data denoising"
    outputSource: qiime_pipeline/denoising_stats
    'sd:visualPlugins':
    - qiime2:
        tab: 'Overview'
        target: "_blank"

  alpha_rarefaction:
    type: File
    label: "Alpha rarefaction curve"
    doc: "plot of OTU rarefaction"
    outputSource: qiime_pipeline/alpha_rarefaction
    'sd:visualPlugins':
    - qiime2:
        tab: 'Overview'
        target: "_blank"

  taxa_bar_plots:
    type: File
    label: "Taxonomic classifications bar plot"
    doc: "bar plot for exploring the taxonomic composition of the sample"
    outputSource: qiime_pipeline/taxa_bar_plots
    'sd:visualPlugins':
    - qiime2:
        tab: 'Overview'
        target: "_blank"

  pcoa_uwunifrac:
    type: File?
    label: "PCoA using unweighted unifrac method"
    doc: "PCoA using unweighted unifrac method"
    outputSource: qiime_pipeline/pcoa_uwunifrac
    'sd:visualPlugins':
    - qiime2:
        tab: 'Overview'
        target: "_blank"

  pcoa_braycurtis:
    type: File?
    label: "PCoA using bray curtis method"
    doc: "PCoA using bray curtis method"
    outputSource: qiime_pipeline/pcoa_braycurtis
    'sd:visualPlugins':
    - qiime2:
        tab: 'Overview'
        target: "_blank"

  heatmap:
    type: File?
    label: "Gneiss differential abundance analysis"
    doc: "Heatmap from gneiss differential abundance analysis using unsupervised correlation-clustering method. This will define the partitions of microbes that commonly co-occur with each other using Ward hierarchical clustering."
    outputSource: qiime_pipeline/heatmap
    'sd:visualPlugins':
    - qiime2:
        tab: 'Overview'
        target: "_blank"

  ancom:
    type: File?
    label: "ANCOM differential abundance analysis"
    doc: "Output from ANCOM differential abundance analysis at user-specified taxonomic level (includes volcano plot)."
    outputSource: qiime_pipeline/ancom
    'sd:visualPlugins':
    - qiime2:
        tab: 'Overview'
        target: "_blank"


steps:

  qiime_pipeline:
    label: "Run pipeline for processing a single 16S metagenomic sample using qiime2"
    doc: |
      Calls shell wrapper for QIIME2's 16S metagenomic processing pipeline.
    run: ../tools/qiime2-aggregate.cwl
    in:
      metadata_file: metadata_file
      pcoa_label: pcoa_label
      sampling_depth: sampling_depth
      diff_group: diff_group
      taxonomic_level:
        source: taxonomic_level
        valueFrom: $(self)
      fastq_r1_array: fastq_r1_array
      fastq_r2_array: fastq_r2_array
      trimLeftF: trimLeftF
      trimLeftR: trimLeftR
      truncLenF: truncLenF
      truncLenR: truncLenR
      threads: threads
    out:
      - overview
      - fastq_summary
      - denoising_stats
      - alpha_rarefaction
      - taxa_bar_plots
      - pcoa_uwunifrac
      - pcoa_braycurtis
      - heatmap
      - ancom
      - log_file_stdout
      - log_file_stderr


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf

s:name: "16S metagenomic paired-end QIIME2 Analysis"
label: "16S metagenomic paired-end QIIME2 Analysis"
s:alternateName: "16S metagenomic paired-end pipeline using QIIME2 for experimental-level (multi-sample) analysis"

s:downloadUrl: https://github.com/datirium/workflows/tree/master/workflows/workflows/qiime2-aggregate.cwl
s:codeRepository: https://github.com/datirium/workflows
s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "Datirium LLC"
  s:location:
  - class: s:PostalAddress
    s:addressCountry: "USA"
    s:addressLocality: "Cincinnati"
    s:addressRegion: "OH"
    s:postalCode: ""
    s:streetAddress: ""
    s:telephone: ""
  s:logo: "https://avatars.githubusercontent.com/u/33202955?s=200&v=4"
  s:department:
  - class: s:Organization
    s:legalName: "Datirium LLC"
    s:department:
    - class: s:Organization
      s:legalName: "Bioinformatics"
      s:member:
      - class: s:Person
        s:name: Robert Player
        s:email: mailto:support@datirium.com
        s:sameAs:
        - id: https://orcid.org/0000-0001-5872-259X


doc: |
  A workflow for processing a multiple 16S samples from within the SciDAP platform, via a QIIME2 pipeline.

  ## __Outputs__
  #### Output files:
    - overview.md, list of inputs
    - demux.qzv, summary visualizations of imported multi-sample data
    - alpha-rarefaction.qzv, plot of multi-sample OTU rarefaction
    - taxa-bar-plots.qzv, relative frequency of taxomonies barplot

  ## __Inputs__
  #### General Info
   - Sample short name/Alias: Used for samplename in downstream analyses. Ensure this is the same name used in the metadata samplesheet.
   - Environment: where the sample was collected
   - Catalog No.: catalog number if available (optional)
   - Read 1 FASTQ file: Read 1 FASTQ file from a paired-end sequencing run.
   - Read 2 FASTQ file: Read 2 FASTQ file that pairs with the input R1 file.
   - Trim 5' of R1: Recommended if adapters are still on the input sequences. Trims the first J bases from the 5' end of each forward read.
   - Trim 5' of R2: Recommended if adapters are still on the input sequences. Trims the first K bases from the 5' end of each reverse read.
   - Truncate 3' of R1: Recommended if quality drops off along the length of the read. Clips the forward read starting M bases from the 5' end (before trimming).
   - Truncate 3' of R2: Recommended if quality drops off along the length of the read. Clips the reverse read starting N bases from the 5' end (before trimming).
   - Threads: Number of threads to use for steps that support multithreading.

  ### __Data Analysis Steps__
  1. Generate FASTX quality statistics for visualization of unmapped, raw FASTQ reads.
  2. Import the data, make a qiime artifact (demux.qza), and summary visualization process will additionally filter any phiX reads (commonly present in marker gene Illumina sequence data) that are identified in the sequencing data, and will filter chimeric sequences.
  4. Generate a phylogenetic tree for diversity analyses and rarefaction processing and plotting.
  5. Taxonomy classification of amplicons. Performed using a Naive Bayes classifier trained on the Greengenes2 database "gg_2022_10_backbone_full_length.nb.qza".

  ### __References__
  1. Bolyen E, Rideout JR, Dillon MR, Bokulich NA, Abnet CC, Al-Ghalith GA, Alexander H, Alm EJ, Arumugam M, Asnicar F, Bai Y, Bisanz JE, Bittinger K, Brejnrod A, Brislawn CJ, Brown CT, Callahan BJ, Caraballo-Rodríguez AM, Chase J, Cope EK, Da Silva R, Diener C, Dorrestein PC, Douglas GM, Durall DM, Duvallet C, Edwardson CF, Ernst M, Estaki M, Fouquier J, Gauglitz JM, Gibbons SM, Gibson DL, Gonzalez A, Gorlick K, Guo J, Hillmann B, Holmes S, Holste H, Huttenhower C, Huttley GA, Janssen S, Jarmusch AK, Jiang L, Kaehler BD, Kang KB, Keefe CR, Keim P, Kelley ST, Knights D, Koester I, Kosciolek T, Kreps J, Langille MGI, Lee J, Ley R, Liu YX, Loftfield E, Lozupone C, Maher M, Marotz C, Martin BD, McDonald D, McIver LJ, Melnik AV, Metcalf JL, Morgan SC, Morton JT, Naimey AT, Navas-Molina JA, Nothias LF, Orchanian SB, Pearson T, Peoples SL, Petras D, Preuss ML, Pruesse E, Rasmussen LB, Rivers A, Robeson MS, Rosenthal P, Segata N, Shaffer M, Shiffer A, Sinha R, Song SJ, Spear JR, Swafford AD, Thompson LR, Torres PJ, Trinh P, Tripathi A, Turnbaugh PJ, Ul-Hasan S, van der Hooft JJJ, Vargas F, Vázquez-Baeza Y, Vogtmann E, von Hippel M, Walters W, Wan Y, Wang M, Warren J, Weber KC, Williamson CHD, Willis AD, Xu ZZ, Zaneveld JR, Zhang Y, Zhu Q, Knight R, and Caporaso JG. 2019. Reproducible, interactive, scalable and extensible microbiome data science using QIIME 2. Nature Biotechnology 37: 852–857. https://doi.org/10.1038/s41587-019-0209-9
    