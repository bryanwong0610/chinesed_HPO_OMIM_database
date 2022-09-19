# chinesed_HPO_OMIM_database
## Generate the OMIM database
### data from :
  Obtained from [OMIM](https://www.omim.org) website
![1280X1280](https://user-images.githubusercontent.com/53446971/190962412-d8125951-0197-4699-b025-8a2839fb3c01.PNG)
### colums need :
`Phenotype`; `Phenotype MIM number ` ; `Inheritance` ; `Gene/Locus`; `Translation_Phenotype`
### database fromation :
![1280X1280-2](https://user-images.githubusercontent.com/53446971/190963153-498c75b9-86e2-4614-b3ed-bbafb9a8e2dc.PNG)

###  the format like: 
<table>
  <tr>
    <td> Gene </td>
    <td> OMIM_en </td>
    <td> OMIM_cn </td>
  </tr>
  <tr>
    <td> P53 </td>
    <td> description_1(OMIM: id);description_2(OMIM: id);etc ... </td>
    <td> cn_description_1(OMIM: id);cn_description_2(OMIM: id);etc ... </td>
  </tr>
</table>

### script method:
 select each gene and loop to select the related omim description

## Generate the HPO database

### data from:
 gene_to_phenotype.txt ; phentype_to_gene.txt 
 this two dataset was downloaded from HPO website. 
 
 CHPO.txt downloaded from CHPO webstie

### database format :
this database was similar like the OMIM

### difference :
***Have two description datasets, and gene related HPO description counts was not equal.***

**Gene ADA as example**
![1280X1280-3](https://user-images.githubusercontent.com/53446971/190968211-5960202c-f7e5-4a34-9dbd-e5ea2ccce917.PNG)
        <p align="center">***Description counts***</p>

If we use the `merge` module in python, some info may lost(see below).

 ![1280X1280-4](https://user-images.githubusercontent.com/53446971/190968492-8d7362ea-0608-412e-be84-341611d31bda.PNG)
                    <p align="center">***Merge module result***</p>
So we need add the judgement method into the script.

![1280X1280-5](https://user-images.githubusercontent.com/53446971/190969646-cbabe0aa-4204-40dd-9e75-1ba47b8cd667.PNG)
        <p align="center">***Add this methodq***</p>


## CWL 
### OMIM database
![1280X1280-6](https://user-images.githubusercontent.com/53446971/190970222-e94a6e0d-e532-4da3-b17c-3cac3275378a.PNG)

### HPO database 
![1280X1280-7](https://user-images.githubusercontent.com/53446971/190970405-af788a32-239b-4696-b255-f9f1d81a683c.PNG)

## annotation :
### key point:

  ***Due to the difference of annotation algorithm between the annotation tools, the same SNP loci may have many gene name(SYMBOL). In order to get more infomation about HPO&OMIM, the first thing we need to do is to get the gene name list of the same SNP loci, and use this list to annnotated the description.***
## annotation CWL:
<img width="535" alt="截屏2022-09-19 15 43 49" src="https://user-images.githubusercontent.com/53446971/190971295-2f83894a-0a14-4259-961c-188e6c012d71.png">

