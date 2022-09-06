class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: omim_generate
baseCommand:
  - python
  - OMIM_generate.py
inputs:
  - id: input_omim
    type: File
    inputBinding:
      position: 0
outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*.csv'
label: OMIM_generate.cwl
requirements:
  - class: DockerRequirement
    dockerPull: 'harbor.bio-it.cn:5000/library/python3.10:latest_3'
  - class: InitialWorkDirRequirement
    listing:
      - entryname: OMIM_generate.py
        entry: "# for generate the OMIM database including chinesed data\r\nimport pandas as pd\r\nimport warnings\r\nwarnings.filterwarnings(\"ignore\")\r\nimport numpy as np\r\nimport sys\r\nimport os\r\ndef omim_generate(input):\r\n    OMIM_new = pd.read_csv(input)\r\n    ##  uniq the omim datasate and add chinesed omim description in to colums, generate the format that we need\r\n    OMIM_ch = []\r\n    OMIM_en = []\r\n    geneSymbol = []\r\n    inheritance = []\r\n\r\n    i = 0\r\n    for i in range(len(OMIM_new['Phenotype MIM number'])):\r\n        des_en = OMIM_new['Phenotype'][i] + '(OMIM:' + str(OMIM_new['Phenotype MIM number'][i]) + ', ' + str(\r\n            OMIM_new['Inheritance'][i]) + ')'\r\n        des_ch = OMIM_new['Translation_Phenotype'][i] + '(OMIM:' + str(\r\n            OMIM_new['Phenotype MIM number'][i]) + ', ' + str(OMIM_new['Inheritance'][i]) + ')'\r\n        symbol = OMIM_new['Gene/Locus'][i]\r\n        OMIM_en.append(des_en)\r\n        OMIM_ch.append(des_ch)\r\n        geneSymbol.append(symbol)\r\n    new_OMIM = {'Gene': geneSymbol, 'OMIM_en': OMIM_en, 'OMIM_ch': OMIM_ch}\r\n    OMIM_trans = pd.DataFrame(new_OMIM)\r\n    geneSymbol_uniq = list(set(geneSymbol))\r\n    ## generate the database format\r\n    dict = {}\r\n    description_save_en = []\r\n    description_save_ch = []\r\n    geneName = []\r\n    for i in range(len(geneSymbol_uniq)):\r\n        my_tmp = ''\r\n        my_tmp_ch = ''\r\n        for k in range(len(geneSymbol)):\r\n            if OMIM_trans['Gene'][k] == geneSymbol_uniq[i]:\r\n                my_tmp += OMIM_trans['OMIM_en'][k] + ';'\r\n                my_tmp_ch += OMIM_trans['OMIM_ch'][k] + ';'\r\n        description_save_en.append(my_tmp[:-1])\r\n        description_save_ch.append(my_tmp_ch[:-1])\r\n        geneName.append(geneSymbol_uniq[i])\r\n    final_dict = {'Gene': geneName, 'OMIM_en': description_save_en, 'OMIM_ch': description_save_ch}\r\n    OMIM_merge = pd.DataFrame(final_dict)\r\n    name = os.path.basename(input).split('_')[0:2]\r\n    OMIM_merge.to_csv('OMIM_' + '_'.join(name) + '.csv', index=False)\r\nif __name__ == '__main__':\r\n    input_omim = sys.argv[1]  #'08_26_all_omim_phenotype_translation.csv'\r\n    #output_omim = sys.argv[2]  #'OMIM_08_26.csv'\r\n    omim_generate(input_omim)\r\n    # name = '08_26_all_omim_phenotype_translation.csv'\r\n    # name = os.path.basename(name).split('_')[0:2]\r\n    # print()"
        writable: false
