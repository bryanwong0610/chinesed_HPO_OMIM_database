import pandas as pd
import numpy as np
import argparse
import sys
import os
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
def argument_get():
    parser=argparse.ArgumentParser(prog='OMIM database generate',description='A python script for generate OMIM database')
    parser.add_argument('--Input','-i',type=str,help='Raw OMIM file')
    args,_ = parser.parse_known_args()
    args = vars(args)
    print(args) #test
    return args
args= argument_get()

## get date 
get_date=date.today()
# load data
OMIM_raw=read_file(args['Input'])
##  uniq the omim datasate and add chinesed omim description in to colums, generate the format that we need 
OMIM_cn=[]
OMIM_en=[]
geneSymbol=[]
inheritance=[]

i=0
for i in range(len(OMIM_raw['Phenotype MIM number'])):
    # get description and symbol
    des_en= OMIM_raw['Phenotype'][i]+'(OMIM:'+ str(OMIM_raw['Phenotype MIM number'][i])+', '+str(OMIM_raw['Inheritance'][i]) + ')'
    des_cn= OMIM_raw['Translation_Phenotype'][i] +'(OMIM:'+ str(OMIM_raw['Phenotype MIM number'][i]) +', '+str(OMIM_raw['Inheritance'][i])+ ')'
    symbol= OMIM_raw['Gene/Locus'][i]
    inher = OMIM_raw['Inheritance'][i]
    OMIM_en.append(des_en)
    OMIM_cn.append(des_cn)
    geneSymbol.append(symbol)
    inheritance.append(inher)
## generate new format OMIM database
new_OMIM={'Gene':geneSymbol,'OMIM_en':OMIM_en,'OMIM_cn':OMIM_cn}
OMIM_trans=pd.DataFrame(new_OMIM)
geneSymbol_uniq=list(set(geneSymbol))
## generate the database format 
dict={}
description_save_en=[]
description_save_cn=[]
geneName=[]
## merge the same gene OMIM description
for i in range(len(geneSymbol_uniq)):
    my_tmp=''
    my_tmp_cn=''
    for k in range(len(geneSymbol)):
        if OMIM_trans['Gene'][k]==geneSymbol_uniq[i] :
            my_tmp+=OMIM_trans['OMIM_en'][k]+';'
            my_tmp_cn+=OMIM_trans['OMIM_cn'][k]+';'
    description_save_en.append(my_tmp[:-1])
    description_save_cn.append(my_tmp_cn[:-1])
    geneName.append(geneSymbol_uniq[i])
    print(geneSymbol_uniq[i] + ' already generating.')
## Generateing  database
final_dict={'Gene':geneName,'OMIM_en':description_save_en,'OMIM_cn':description_save_cn}
OMIM_merge=pd.DataFrame(final_dict)
res_name='./OMIM_'+ get_date.year + '_' + get_date.month + '_' + get_date.day + '.csv' 
OMIM_merge.to_csv(res_name,index=False)