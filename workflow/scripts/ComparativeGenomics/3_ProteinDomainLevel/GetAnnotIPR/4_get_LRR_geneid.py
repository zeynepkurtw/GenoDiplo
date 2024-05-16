import pandas as pd

"""
This script;
gets the gene_ids from HIN with LRR superfamily
"""
family ="LRR"
sp = "HIN"

top7sf = "output/interproscan/processed_data/ann_ipr_cat_top7sf.csv" #get pfam domains

out_file = f"""output/interproscan/processed_data/{family}_geneid.csv""" # get gene_ids with pfam domains


df= pd.read_csv(top7sf, header="infer", sep="\t")
df_family = df.groupby(["family", "sp"]).get_group((family, sp))[["id", "ipr"]].drop_duplicates() #get gene ids from the family
#df_family = df.groupby(["sp","family", "ipr"]).size()
#df_family = df.groupby("family").get_group("LRR")["ipr"].drop_duplicates()

df_family.to_csv(out_file, index=False, sep="\t", header=None)
