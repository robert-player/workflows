#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
- $import: ./metadata/envvar-global.yml
- class: InlineJavascriptRequirement
- class: ShellCommandRequirement

inputs:

  script:
    type: string?
    default: |
      #!/usr/bin/env python
      import sys, re
      fragments, islands = 0, 0
      with open(sys.argv[1], 'r') as infile:
        for line in infile:
            if re.match('^# d = ', line):
                fragments = int(line.split('d = ')[1])
                continue
            if re.match('^#', line):
                continue
            if line.strip() != "":
                islands = islands + 1
      islands = islands - 1
      print fragments, '\n', islands
    inputBinding:
      position: 5
    doc: |
      Python script to get ISLANDS and FRAGMENTS from MACS2 output

  input_file:
    type: File
    inputBinding:
      position: 6
    doc: |
      Output file from MACS2 peak calling

outputs:

  fragments:
    type: int
    outputBinding:
      loadContents: true
      glob: "island_count.log"
      outputEval: $(parseInt(self[0].contents.split(/\r?\n/)[0]))

  islands:
    type: int
    outputBinding:
      loadContents: true
      glob: "island_count.log"
      outputEval: $(parseInt(self[0].contents.split(/\r?\n/)[1]))

baseCommand: [python, '-c']
arguments:
  - valueFrom: $(" > island_count.log")
    position: 100000
    shellQuote: false

$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html

s:mainEntity:
  $import: ./metadata/macs2-metadata.yaml

s:name: "macs2-island-count"
s:downloadUrl: https://raw.githubusercontent.com/SciDAP/workflows/master/tools/macs2-island-count.cwl
s:codeRepository: https://github.com/SciDAP/workflows
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
        s:email: mailto:michael.kotliar@cchmc.org
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898

doc: |
  Tool is used to return an estimated fragment size and islands count from
  xls file generated by MACS2 callpeak

s:about: >
  Runs python code from the script input
