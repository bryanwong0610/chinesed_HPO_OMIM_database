class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: hpo_dt_generate
baseCommand:
  - python
  - HPO_generate.py
inputs:
  - id: CHPO_raw
    type: File?
    inputBinding:
      position: 0
      prefix: '-CHPO'
      shellQuote: false
  - id: HPO_gene2phen
    type: File?
    inputBinding:
      position: 0
      prefix: '-HG2P'
      shellQuote: false
  - id: HPO_phen2gene
    type: File?
    inputBinding:
      position: 0
      prefix: '-HP2G'
      shellQuote: false
outputs:
  - id: output
    type: File?
    outputBinding:
      glob: '*.csv'
label: HPO_dt_generate
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'harbor.bio-it.cn:5000/library/python_3.9:chen_v1'
  - class: InitialWorkDirRequirement
    listing:
      - entryname: HPO_generate.py
        entry: >
          import pandas as pd

          import numpy as np

          import argparse

          #import sys

          #import os

          from datetime import date


          # read file & argument set up 

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
          # argument 

          def argument_get():
              parser=argparse.ArgumentParser(prog='OMIM database generate',description='A python script for generate OMIM database')
              parser.add_argument('--HPO_Gene2Phen','-HG2P',type=str,help='Raw Gene to Phenotype file')
              parser.add_argument('--HPO_Phen2Gene','-HP2G',type=str,help='Raw Phenotype to Gene file')
              parser.add_argument('--CHPO','-CHPO',type=str,help='Raw CHPO database')
              args,_ = parser.parse_known_args()
              args = vars(args)
              print(args) #test
              return args
          args= argument_get()


          # date 

          get_date=date.today()


          ## load data

          HPO_phen2gene=read_file(args['HPO_Phen2Gene'])

          HPO_gene2phen=read_file(args['HPO_Gene2Phen'])

          CHPO_raw=read_file(args['CHPO'])

          ##  change headr name 

          HPO_phen2gene.rename(columns={0:'HPO_id',1:'HPO_description',2:'entrez_id',3:'Gene_symbol'},inplace=True)

          HPO_gene2phen.rename(columns={0:'entrez_id',1:'Gene_symbol',2:'HPO_id',3:'HPO_description'},inplace=True)

          hpo_gene_phen2gen=list(set(HPO_phen2gene['Gene_symbol']))

          hpo_gene_ge2ph=list(set(HPO_gene2phen['Gene_symbol']))

          HPO_gene_list=list(set(hpo_gene_ge2ph+hpo_gene_phen2gen)) ## get uniq
          gene 


          # generating the file 

          HPO_en=[]

          HPO_cn=[]

          gene_symbol=[]

          for gene in HPO_gene_list:
              df_ph2ge=HPO_phen2gene[HPO_phen2gene['Gene_symbol']==gene] ## select the set for one gene from phen2gene dt
              df_ge2ph=HPO_gene2phen[HPO_gene2phen['Gene_symbol']==gene] ## select the set for one gene from gene2phen dt 
              df_ph2ge=df_ph2ge.reset_index(drop=True) ### re-select dataframe index will lose!
              df_ge2ph=df_ge2ph.reset_index(drop=True) ## reset index 
              HPO_id_list_ge2ph=list(df_ge2ph['HPO_id'])
              HPO_id_list_ph2ge=list(df_ph2ge['HPO_id'])
              HPO_id_list=HPO_id_list_ge2ph+HPO_id_list_ph2ge
              HPO_id_list=list(set(HPO_id_list)) ## get uniq HPO id 
              HPO_id_description=[]
              HPO_id_description
              str_cn=''
              str_en=''
              for id in HPO_id_list:
                  for chinesed in range(len(CHPO_raw)):   ## get CHPO info         
                      if id == str(CHPO_raw['HPO_id'][chinesed]):
                          str_cn += str(CHPO_raw['HPO_id'][chinesed]) + '(' + str(CHPO_raw['HPO_name'][chinesed]) + ')'+';' 
                  for abc in range(len(df_ge2ph)): ## get gene2phen each HPO description 
                      if id == str(df_ge2ph['HPO_id'][abc]):
                         str_en += str(df_ge2ph['HPO_id'][abc]) + '(' + str(df_ge2ph['HPO_description'][abc]) + ')' + ';'
                  for raw_2 in range(len(df_ph2ge)):
                      if id == str(df_ph2ge['HPO_id'][raw_2]):
                          if str(df_ph2ge['HPO_id'][raw_2]) in str_en: # judge the HPOid is already in phen2gene database if already exist will not add 
                              str_en=str_en  
                          else: # if do not exist, add this id & description in the list 
                              str_en += str(df_ph2ge['HPO_id'][raw_2]) + '(' + str(df_ph2ge['HPO_description'][raw_2]) + ')' + ';'
              gene_symbol.append(gene)
              HPO_cn.append(str_cn[:-1])
              HPO_en.append(str_en[:-1])
              print(gene + ' already generating.')
          # generating 

          merge_dt={'Gene_symbol':gene_symbol,'HPO_en':HPO_en,'HPO_cn':HPO_cn}

          merge_dt=pd.DataFrame(merge_dt)

          res_name='./HPO_' + get_date.year + '_' + get_date.month +'_' +
          get_date.day +'.csv'

          merge_dt.to_csv(res_name,index=False)
        writable: false
