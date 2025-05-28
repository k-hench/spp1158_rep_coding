"""
snakemake -n step1
snakemake -c 1 step3
"""
# --- setting up snakemake varioables ---
# different expected number of clusters
# dependent on fractal-level
n_clusters = [ 6, 36, 216, 1296 ]

# --- definging "target rules" ---
rule step1:
   input: "../data/cluster_buster.tsv"

rule step2:
   input: expand("../results/kmeans/cluster_{nclust}.tsv", nclust = n_clusters)

rule step3:
   input: expand("../results/summary/kmeans_{nclust}.tsv", nclust = n_clusters)

# --- defining "worker rules"  ---
rule create_data:
  output:
    tsv = "../data/cluster_buster.tsv",
    pdf = "../results/img/cluster_generation.pdf"
  shell:
    '''
    Rscript --vanilla R/cluster_buster.R
    '''

rule run_clustering:
    input:
      tsv = "../data/cluster_buster.tsv"
    output:
      tsv = "../results/kmeans/cluster_{nclust}.tsv"
    shell:
      """
      python py/clustering.py \
        -n {wildcards.nclust} \
        -i {input.tsv} -o {output.tsv}
      """

rule cluster_stats:
  input:
    tsv = "../results/kmeans/cluster_{nclust}.tsv"
  output:
     tsv = "../results/summary/kmeans_{nclust}.tsv",
     pdf = "../results/img/assigned_{nclust}_clusters.pdf",
     rds = "../results/img/R/assigned_{nclust}_clusters.Rds"
  shell:
    '''
    Rscript --vanilla R/summarise_clusters.R {wildcards.nclust}
    '''