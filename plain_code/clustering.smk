"""
snakemake -n step1
snakemake -c 1 step1
"""
# --- definging "target rules" ---
rule step1:
   input: "../data/cluster_buster.tsv"

# --- defining "worker rules"  ---
rule create_data:
  output:
    tsv = "../data/cluster_buster.tsv",
    pdf = "../results/img/cluster_generation.pdf"
  shell:
    '''
    Rscript --vanilla R/cluster_buster.R
    '''
 