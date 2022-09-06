# for generate the OMIM database including chinesed data
import pandas as pd
import warnings
warnings.filterwarnings("ignore")
import numpy as np
import sys
import os
OMIM_new=pd.read_csv('08_26_all_omim_phenotype_translation.csv')
##  uniq the omim datasate and add chinesed omim description in to colums, generate the format that we need 
OMIM_ch=[]
OMIM_en=[]
geneSymbol=[]
inheritance=[]

i=0
for i in range(len(OMIM_new['Phenotype MIM number'])):
    des_en= OMIM_new['Phenotype'][i]+'(OMIM:'+ str(OMIM_new['Phenotype MIM number'][i])+', '+str(OMIM_new['Inheritance'][i]) + ')'
    des_ch= OMIM_new['Translation_Phenotype'][i] +'(OMIM:'+ str(OMIM_new['Phenotype MIM number'][i]) +', '+str(OMIM_new['Inheritance'][i])+ ')'
    symbol= OMIM_new['Gene/Locus'][i]
    #inher = OMIM_new['Inheritance'][i]
    OMIM_en.append(des_en)
    OMIM_ch.append(des_ch)
    geneSymbol.append(symbol)
    #inheritance.append(inher)
new_OMIM={'Gene':geneSymbol,'OMIM_en':OMIM_en,'OMIM_ch':OMIM_ch}
OMIM_trans=pd.DataFrame(new_OMIM)
geneSymbol_uniq=list(set(geneSymbol))
## generate the database format 
dict={}
description_save_en=[]
description_save_ch=[]
geneName=[]
for i in range(len(geneSymbol_uniq)):
    my_tmp=''
    my_tmp_ch=''
    for k in range(len(geneSymbol)):
        if OMIM_trans['Gene'][k]==geneSymbol_uniq[i] :
            my_tmp+=OMIM_trans['OMIM_en'][k]+';'
            my_tmp_ch+=OMIM_trans['OMIM_ch'][k]+';'
    description_save_en.append(my_tmp[:-1])
    description_save_ch.append(my_tmp_ch[:-1])
    geneName.append(geneSymbol_uniq[i])
final_dict={'Gene':geneName,'OMIM_en':description_save_en,'OMIM_ch':description_save_ch}   
OMIM_merge=pd.DataFrame(final_dict)
OMIM_merge.to_csv('OMIM_08_26.csv',index=False)