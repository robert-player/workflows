cwlVersion: v1.0
class: CommandLineTool


requirements:
  - class: ResourceRequirement
    ramMin: 15250
    coresMin: 1
  - class: InlineJavascriptRequirement
    expressionLib:
    - var default_output_filename = function() {
            var basename = inputs.bedgraph_file.location.split('/').slice(-1)[0];
            var root = basename.split('.').slice(0,-1).join('.');
            var ext = ".bigWig";
            return (root == "")?basename+ext:root+ext;
          };


hints:
- class: DockerRequirement
  dockerPull: biowardrobe2/ucscuserapps:v358


inputs:

  bedgraph_file:
    type: File
    inputBinding:
      position: 10
    doc: |
      Four column bedGraph file: <chrom> <start> <end> <value>

  chrom_length_file:
    type: File
    inputBinding:
      position: 11
    doc: |
      Two-column chromosome length file: <chromosome name> <size in bases>

  unc:
    type: boolean?
    inputBinding:
      position: 5
      prefix: "-unc"
    doc: |
      Disable compression

  items_per_slot:
    type: int?
    inputBinding:
      separate: false
      position: 6
      prefix: "-itemsPerSlot="
    doc: |
      Number of data points bundled at lowest level. Default 1024

  block_size:
    type: int?
    inputBinding:
      separate: false
      position: 7
      prefix: "-blockSize="
    doc: |
      Number of items to bundle in r-tree.  Default 256

  output_filename:
    type: string?
    inputBinding:
      position: 12
      valueFrom: |
        ${
            if (self == ""){
              return default_output_filename();
            } else {
              return self;
            }
        }
    default: ""
    doc: |
      If set, writes the output bigWig file to output_filename,
      otherwise generates filename from default_output_filename()


outputs:

  error_msg:
    type: File?
    outputBinding:
      glob: "error_msg.txt"

  error_report:
    type: File?
    outputBinding:
      glob: "error_report.txt"

  bigwig_file:
    type: File
    outputBinding:
      glob: |
        ${
            if (inputs.output_filename == ""){
              return default_output_filename();
            } else {
              return inputs.output_filename;
            }
        }


baseCommand: ["bedGraphToBigWig"]
stdout: error_msg.txt
stderr: error_msg.txt


label: "ucsc-bedgraphtobigwig"
doc: |
  Tool converts bedGraph to bigWig file.

  `default_output_filename` function returns filename for generated bigWig if `output_filename` is not provided.
  Default filename is generated on the base of `bedgraph_file` basename with the updated to `*.bigWig` extension.

  usage:
     bedGraphToBigWig in.bedGraph chrom.sizes out.bw
  where in.bedGraph is a four column file in the format:
        <chrom> <start> <end> <value>
  and chrom.sizes is a two-column file/URL: <chromosome name> <size in bases>
  and out.bw is the output indexed big wig file.
  If the assembly <db> is hosted by UCSC, chrom.sizes can be a URL like
    http://hgdownload.cse.ucsc.edu/goldenPath/<db>/bigZips/<db>.chrom.sizes
  or you may use the script fetchChromSizes to download the chrom.sizes file.
  If not hosted by UCSC, a chrom.sizes file can be generated by running
  twoBitInfo on the assembly .2bit file.
  The input bedGraph file must be sorted, use the unix sort command:
    sort -k1,1 -k2,2n unsorted.bedGraph > sorted.bedGraph
  options:
     -blockSize=N - Number of items to bundle in r-tree.  Default 256
     -itemsPerSlot=N - Number of data points bundled at lowest level. Default 1024
     -unc - If set, do not use compression.
