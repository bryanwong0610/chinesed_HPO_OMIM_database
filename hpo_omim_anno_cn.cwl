class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: hpo_omim_anno_cn
baseCommand:
  - python
  - OMIM_HPO_anno.py
inputs:
  - id: UnAnno_file
    type: File?
    inputBinding:
      position: 1
      prefix: '-i'
      shellQuote: false
  - id: HPO_db
    type: File?
    inputBinding:
      position: 3
      prefix: '-H'
      shellQuote: false
  - id: OMIM_db
    type: File?
    inputBinding:
      position: 5
      prefix: '-O'
      shellQuote: false
outputs:
  - id: Annotated_data
    type: File?
    outputBinding:
      glob: H_O_annotated.csv
label: HPO_OMIM_Anno_cn
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'harbor.bio-it.cn:5000/library/python_3.9:chen_v1'
  - class: InitialWorkDirRequirement
    listing:
      - entryname: OMIM_HPO_anno.py
        entry: |
          import pandas as pd 
          import numpy as np
          import argparse

          def argument_get():
              parser=argparse.ArgumentParser(prog='OMIM HPO annotated script',description='A python script for cwl for annotated HPO and OMIM')
              parser.add_argument('--Input','-i',type=str,help='A file contain the gene name')
              parser.add_argument('--OMIM_DB','-O',type=str,help='OMIM database directory')
              parser.add_argument('--HPO_DB','-H',type=str,help='HPO database directory')
              args,_ = parser.parse_known_args()
              args = vars(args)
              print(args) #test
              return args
          args= argument_get()
          def read_file(input,write=False,writeData=None):
              file_type=input.split('.')[-1]
              if file_type =='xlxs':
                  file=pd.read_excel(input)
              elif file_type == 'xls':
                  file=pd.read_excel(input)
              elif file_type == 'csv':
                  file=pd.read_csv(input)
              elif file_type == 'txt':
                  file=pd.read_csv(input,sep='\t')
              return file
          OMIM=read_file(args['OMIM_DB'])
          HPO=read_file(args['HPO_DB'])
          result=read_file(args['Input'])
          #OMIM=pd.read_csv('OMIM_08_26.csv',sep=',')
          #HPO=pd.read_csv('HPO_merged.csv')
          #gene_info=pd.read_csv('./Gene_info/gene_info.csv',sep=',')
          #result=pd.read_csv('SALS_Final_variation_filterd.csv',dtype=str)
          OMIM_res_en=[]
          OMIM_res_cn=[]
          HPO_res_en=[]
          HPO_res_cn=[]
          for i in range(len(result)):
              gene_list=[]
              if result['Gene.refGene'][i] != result['Gene.ensGene'][i]:
                  if ';' in result['Gene.refGene'][i]:
                      gene_list=result['Gene.refGene'][i].split(';')
                      if ';' in result['Gene.ensGene'][i] :
                          gene_list=gene_list+result['Gene.ensGene'][i].split(';')
                      else:
                          gene_list.append(result['Gene.ensGene'][i])
                  else :
                      gene_list.append(result['Gene.refGene'][i])
                      if ';' in result['Gene.ensGene'][i]:
                          gene_list=gene_list+result['Gene.ensGene'][i].split(';')
                      else :
                          gene_list.append(result['Gene.ensGene'][i])
              elif result['Gene.refGene'][i] == result['Gene.ensGene'][i]:
                  if ';' in result['Gene.refGene'][i]:
                      gene_list=result['Gene.refGene'][i].split(';')
                  else:
                      gene_list.append(result['Gene.refGene'][i])
              if len(gene_list) >= 1 :
                  tmp_en=''
                  tmp_cn=''
                  HPO_tmp_en=''
                  HPO_tmp_cn=''
                  for k in gene_list:
                      for m in range(len(OMIM['Gene'])):
                          if OMIM['Gene'][m] == k :
                              tmp_en += k + ':' + OMIM['OMIM_en'][m] + '|'
                              tmp_cn += k + ':' + OMIM['OMIM_cn'][m] + '|'
                      for n in range(len(HPO)):
                          if HPO['Gene_symbol'][n] == k:
                              HPO_tmp_en += k+':'+ HPO['HPO_en'][n] + '|'
                              HPO_tmp_cn += k + ':' + HPO['HPO_cn'][n] + '|'
                  tmp_en=tmp_en[:-1]
                  tmp_cn=tmp_cn[:-1]
                  HPO_tmp_en=HPO_tmp_en[:-1]
                  HPO_tmp_cn=HPO_tmp_cn[:-1]
                  OMIM_res_en.append(tmp_en)
                  OMIM_res_cn.append(tmp_cn)
                  HPO_res_en.append(HPO_tmp_en)
                  HPO_res_cn.append(HPO_tmp_cn)
              else:
                  tmp_en=''
                  tmp_cn=''
                  HPO_tmp_en=''
                  HPO_tmp_cn=''
                  OMIM_res_en.append(tmp_en)
                  OMIM_res_cn.append(tmp_cn)
                  HPO_res_en.append(HPO_tmp_en)
                  HPO_res_cn.append(HPO_tmp_cn)
          result['OMIM_en']=OMIM_res_en
          result['OMIM_cn']=OMIM_res_cn
          result['HPO_en']=HPO_res_en
          result['HPO_cn']=HPO_res_cn    

          result.to_csv('./H_O_annotated.csv')
        writable: false
