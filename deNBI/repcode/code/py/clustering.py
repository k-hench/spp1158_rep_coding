import session_info                              # to capture the computing environment
import os                                        # to create target directories
import pandas as pd                              # to help organize data
import numpy as np                               # for number crunching
from sklearn.decomposition import PCA            # PCA method
from sklearn.cluster import KMeans               # k-means clustering method
from sklearn.preprocessing import StandardScaler # to normalize data

# Set the random seed for reproducibility
np.random.seed(42)

# Load data from TSV file, first three lines are comments
data = pd.read_csv('data/penguins.tsv', delimiter='\t', skiprows=3)

# The PCA can not operate on NA values
data = data.dropna()

# Reset the index of the original data DataFrame
data.reset_index(drop=True, inplace=True)

# store names of columns with morpholgy data
morph_col_names = ['bill_length_mm', 'bill_depth_mm', 'flipper_length_mm', 'body_mass_g']

# Select columns with morphology data for PCA
X = data[morph_col_names]

# Standardize the features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Perform PCA (with reproducible seed)
pca = PCA(n_components=2, random_state=np.random.randint(1e6))  # We'll keep only the first 2 principal components for visualization
X_pca = pca.fit_transform(X_scaled)

# Perform KMeans clustering, trying to detect the three species (with reproducible seed)
kmeans = KMeans(n_clusters=3, random_state=np.random.randint(1e6))  # You can adjust the number of clusters as needed
kmeans.fit(X_scaled)
cluster_labels = kmeans.labels_

# Combine clustering labels, PC1, PC2 values, and the original data into a DataFrame
combined_data = pd.concat([data,
                           pd.DataFrame({'PC1': X_pca[:, 0], 
                                         'PC2': X_pca[:, 1],
                                         'cluster': cluster_labels})], axis=1)

# Get cluster centers in original feature space
cluster_centers = kmeans.cluster_centers_

# Reverse the scaling operation to obtain centroids in the original feature space
cluster_centers_original = scaler.inverse_transform(kmeans.cluster_centers_)

# Get inertia (intra-cluster sum of squares)
inertia = kmeans.inertia_

# Transform cluster centers to PCA space
cluster_centers_pca = pca.transform(cluster_centers)

# Calculate semi-major and semi-minor axes lengths and rotation angle for each cluster
# to be able to draw ellipses for the clusters
semi_major_axes = []
semi_minor_axes = []
rotation_angles = []

for i, cluster_center in enumerate(cluster_centers_pca):
    # Calculate covariance matrix for the cluster
    cov_matrix = np.cov(X_pca[cluster_labels == i].T)
    # Calculate semi-major and semi-minor axes lengths
    eig_vals, eig_vecs = np.linalg.eig(cov_matrix)
    semi_major_axes.append(np.sqrt(inertia / len(X_pca)) * np.sqrt(eig_vals[0]))
    semi_minor_axes.append(np.sqrt(inertia / len(X_pca)) * np.sqrt(eig_vals[1]))
    # Calculate angle of rotation
    rotation_angle = np.degrees(np.arctan2(eig_vecs[1, 0], eig_vecs[0, 0]))
    rotation_angles.append(rotation_angle)

# Adjust the angle of rotation to match R's coordinate system
rotation_angles_adjusted = [(angle + 180) % 360 for angle in rotation_angles]

# Create a DataFrame to store the centroid positions and ellipse parameters
cluster_data = pd.DataFrame({
    'cluster': range(len(cluster_centers)),
    'centroid_{nm}'.format(nm = morph_col_names[0]) : cluster_centers_original[:, 0],
    'centroid_{nm}'.format(nm = morph_col_names[1]) : cluster_centers_original[:, 1],
    'centroid_{nm}'.format(nm = morph_col_names[2]) : cluster_centers_original[:, 2],
    'centroid_{nm}'.format(nm = morph_col_names[3]) : cluster_centers_original[:, 3],
    'centroid_PC1': cluster_centers_pca[:, 0],
    'centroid_PC2': cluster_centers_pca[:, 1],
    'semi_major_axis': semi_major_axes,
    'semi_minor_axis': semi_minor_axes,
    'rotation_angle': rotation_angles_adjusted
})

# Create the "results" folder if it doesn't exist
if not os.path.exists('results'):
    os.makedirs('results')

# Define the file paths for the TSV files
output_data = 'results/clustered_penguins.tsv'
output_cluster = 'results/clustered_centroids.tsv'

# Export the combined_data DataFrame to a TSV file
combined_data.to_csv(output_data, sep='\t', index=False)

# Export the cluster_data DataFrame to a TSV file
cluster_data.to_csv(output_cluster, sep='\t', index=False)

# Log session information
print("python packages used:\n---------------")
session_info.show()
print("---------------\n")