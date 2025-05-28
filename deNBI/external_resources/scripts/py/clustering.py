#!/usr/bin/env python
# import required python packages
import argparse                                  # to accept command line arguments 
import sys                                       # for error messages
import pandas as pd                              # to help organize data
import numpy as np                               # for number crunching
from sklearn.cluster import KMeans               # k-means clustering method

# wrap the cluster assignment into function
def cluster_data(infile, nclust):
    # Set the random seed for reproducibility
    np.random.seed(42)
    
    # Load data from tsv file
    data = pd.read_csv(infile, delimiter='\t')
      
    # Perform KMeans clustering, get number
    # of clusters from command line argument 
    # (with reproducible seed)
    kmeans = KMeans(n_clusters=int(nclust), random_state=np.random.randint(1e6))
    kmeans.fit(data)
    cluster_labels = kmeans.labels_
    
    # Combine clustering labels and the original data into a DataFrame
    combined_data = pd.concat([data,
                               pd.DataFrame({'cluster': cluster_labels})], axis=1)
    
    # return the labeled data back to main
    return combined_data

# main function to process the command line arguments and
# call the clustering process
def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="apply k-means clustering to x/y data")
    parser.add_argument('-n', '--cluster-number', dest="nclust", help="Number of clusters to assign")
    parser.add_argument('-o', '--output', dest="output_file", default="/dev/stdout", help="Output tsv file (default: stdout)")
    parser.add_argument('-i', '--input', dest='data_file', help="Input data file (tsv, 2 columns 'x' & ;'y')")
    args = parser.parse_args()
    
    try:
        # run the clustering function
        data = cluster_data(args.data_file, args.nclust)
        # export the combined_data DataFrame to a tsv file
        data.to_csv(args.output_file, sep='\t', index=False)

    # error processing
    except ValueError as e:
        print("Error:", e, file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
