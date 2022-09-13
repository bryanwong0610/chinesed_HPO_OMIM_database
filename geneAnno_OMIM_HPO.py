import pandas as pd 
import numpy as np
OMIM=pd.read_csv('OMIM_08_26.csv',sep=',')
HPO=pd.read_csv('HPO_merged.csv')
gene_info=pd.read_csv('./Gene_info/gene_info.csv',sep=',')
result=pd.read_csv('SALS_Final_variation_filterd.csv',dtype=str)
OMIM_res_en=[]
OMIM_res_ch=[]
HPO_res_en=[]
HPO_res_ch=[]
for i in range(len(result)):
    gene_list=[]
    if result['Gene_refGene'][i] != result['Gene_ensGene'][i]:
        if ';' in result['Gene_refGene'][i]:
            gene_list=result['Gene_refGene'][i].split(';')
            if ';' in result['Gene_ensGene'][i] :
                gene_list=gene_list+result['Gene_ensGene'][i].split(';')
            else:
                gene_list.append(result['Gene_ensGene'][i])
        else :
            gene_list.append(result['Gene_refGene'][i])
            if ';' in result['Gene_ensGene'][i]:
                gene_list=gene_list+result['Gene_ensGene'][i].split(';')
            else :
                gene_list.append(result['Gene_ensGene'][i])
    elif result['Gene_refGene'][i] == result['Gene_ensGene'][i]:
        if ';' in result['Gene_refGene'][i]:
            gene_list=result['Gene_refGene'][i].split(';')
        else:
            gene_list.append(result['Gene_refGene'][i])
    if len(gene_list) >= 1 :
        tmp_en=''
        tmp_ch=''
        HPO_tmp_en=''
        HPO_tmp_ch=''
        for k in gene_list:
            for m in range(len(OMIM['Gene'])):
                if OMIM['Gene'][m] == k :
                    tmp_en += k + ':' + OMIM['OMIM_en'][m] + '|'
                    tmp_ch += k + ':' + OMIM['OMIM_ch'][m] + '|'
            for n in range(len(HPO)):
                if HPO['Gene_symbol'][n] == k:
                    HPO_tmp_en += k+':'+ HPO['HPO_en'][n] + '|'
                    HPO_tmp_ch += k + ':' + HPO['HPO_ch'][n] + '|'
        tmp_en=tmp_en[:-1]
        tmp_ch=tmp_ch[:-1]
        HPO_tmp_en=HPO_tmp_en[:-1]
        HPO_tmp_ch=HPO_tmp_ch[:-1]
        OMIM_res_en.append(tmp_en)
        OMIM_res_ch.append(tmp_ch)
        HPO_res_en.append(HPO_tmp_en)
        HPO_res_ch.append(HPO_tmp_ch)
    else:
        tmp_en=''
        tmp_ch=''
        HPO_tmp_en=''
        HPO_tmp_ch=''
        OMIM_res_en.append(tmp_en)
        OMIM_res_ch.append(tmp_ch)
        HPO_res_en.append(HPO_tmp_en)
        HPO_res_ch.append(HPO_tmp_ch)
result['OMIM_en']=OMIM_res_en
result['OMIM_ch']=OMIM_res_ch
result['HPO_en']=HPO_res_en
result['HPO_ch']=HPO_res_ch    

result.to_csv('./New_HPO.csv')