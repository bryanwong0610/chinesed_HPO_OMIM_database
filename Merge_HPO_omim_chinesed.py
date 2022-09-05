import pandas as pd
import warnings
warnings.filterwarnings("ignore")
import numpy as np
import sys
import os
def dataread(input,write=False,writeData=None):
    file_type=input.split('.')[-1]
    if file_type == 'xlsx':
        file=pd.read_excel(input)
    elif file_type == 'txt':
        file=pd.read_csv(input,sep='\t')
    elif file_type == 'csv':
        file=pd.read_csv(input)
    return file
## loading the file 
HPO_old=pd.read_csv('DBHPO.csv')
HPO_Gene=pd.read_csv('HPO_relates_Disease/HPO_relates_Disease.csv')
HPO_ch=pd.read_csv('HPO_relates_Disease/HPO_datasets_20220722.csv')
HPO_phen2gene=pd.read_csv('phenotype_to_genes.txt',sep='\t', header=None)
HPO_gene2phen=pd.read_csv('genes_to_phenotype.txt',sep='\t', header=None)
CHPO_raw=pd.read_csv('CHPO.csv',dtype=str)
omim=pd.read_csv('08_26_all_omim_phenotype_translation.csv')
omim_chinesed=pd.read_csv('OMIM_08_26.csv')
## change the raw_data 
HPO_phen2gene.keys()
col_name={0:'entrez_id',1:'Gene_symbol',2:'HPO_id',3:'HPO_description'}
HPO_phen2gene.rename(columns={0:'HPO_id',1:'HPO_description',2:'entrez_id',3:'Gene_symbol'},inplace=True)
HPO_gene2phen.rename(columns=col_name,inplace=True)
hpo_gene_phen2gen=list(set(HPO_phen2gene['Gene_symbol']))
hpo_gene_nc=list(set(HPO_Gene['entrezGeneSymbol']))
hpo_gene_ge2ph=list(set(HPO_gene2phen['Gene_symbol']))
hpo_gene_old_db=list(set(HPO_old['id']))
omim_genn=list(set(omim['Gene/Locus']))
hpo_id_phen2gen=list(set(HPO_phen2gene['HPO_id']))
hpo_id_nc=list(set(HPO_Gene['HPO_id']))
hpo_id_ge2ph=list(set(HPO_gene2phen['HPO_id']))
hpo_id_judge=[]
omim_id_jude=[]
hpo_gene_phVgen_ju=[]
for i in range(len(hpo_id_phen2gen)):
    if hpo_id_phen2gen[i] in hpo_gene_ge2ph:
        str='T'
    else:
        str='F'
    hpo_id_judge.append(str)
    if hpo_id_phen2gen[i] in omim_genn:
        str='T'
    else:
        str='F'
    omim_id_jude.append(str)
for i in range(len(hpo_gene_ge2ph)):
    if hpo_gene_ge2ph[i] in hpo_gene_phen2gen:
        str='T'
    else:
        str='F'
    hpo_gene_phVgen_ju.append(str)
Counts={'hpo_gene':hpo_gene_phVgen_ju}
Counts=pd.DataFrame(Counts)
gene_counts=pd.value_counts(Counts['hpo_gene'])
#pd.value_counts(CHPO_raw['HPO_name'])
CHPO_raw
print(CHPO_raw.dtypes)
CHPO_raw['HPO_name']= CHPO_raw['HPO_name'].astype(np.str)
print(CHPO_raw.dtypes)


# get the list 
HPO_description=[]
HPO_description_ch=[]
HPO_description_merge=[]
HPO_description_merge_ch=[]
gene_symbol=[]


## merge HPO info 
for i in hpo_gene_ge2ph:
    for k in range(len(HPO_phen2gene)):
        if i == HPO_phen2gene['Gene_symbol'][k]:
            str_tmp_ph2gen_en=HPO_phen2gene['HPO_description'][k]+ ' (' + HPO_phen2gene['HPO_id'][k] + ')'
            for kk in range(len(CHPO_raw)):
                if HPO_phen2gene['HPO_id'][k] == CHPO_raw['HPO_id'][kk]:
                    str_tmp_ph2gen_ch=  CHPO_raw['HPO_name'][kk] + '(' + HPO_phen2gene['HPO_id'][k] + ')'
                    HPO_description_ch.append(str_tmp_ph2gen_ch)
            HPO_description.append(str_tmp_ph2gen_en)
    for m in range(len(HPO_gene2phen)):
        if i == HPO_gene2phen['Gene_symbol'][m]:
            str_tmp_ge2ph_en= HPO_gene2phen['HPO_description'][m]+ ' (' + HPO_gene2phen['HPO_id'][m] + ')'
            for mm in range(len(CHPO_raw)):
                if HPO_gene2phen['HPO_id'][m] == CHPO_raw['HPO_id'][mm]:
                    str_tmp_ge2ph_ch= CHPO_raw['HPO_name'][mm] + '(' + HPO_gene2phen['HPO_id'][m] + ')'
                    HPO_description_ch.append(str_tmp_ge2ph_ch)
            HPO_description.append(str_tmp_ge2ph_en)
    HPO_description_uniq=list(set(HPO_description))
    HPO_description_ch_uniq=list(set(HPO_description_ch))
    #print(HPO_description_uniq)
    tmp=''
    tmp_2=''
    for x in HPO_description_uniq:
        tmp += x + ';'
    str_tmp=tmp[:-1]
    for z in HPO_description_ch_uniq:
        tmp_2 += z + ';'
    str_tmp_ch= tmp_2[:-1]
    #print(str_tmp)
    HPO_description_merge.append(str_tmp)
    HPO_description_merge_ch.append(str_tmp_ch)
    gene_symbol.append(i)
    print('The gene ' + i + ' merged')
## generate
New_HPO_data={'Gene_symbol':gene_symbol,'HPO_en':HPO_description_merge,'HPO_ch':HPO_description_merge_ch}
New_data=pd.DataFrame(New_HPO_data)
New_data.to_csv('HPO_merged.csv',index=False)    
