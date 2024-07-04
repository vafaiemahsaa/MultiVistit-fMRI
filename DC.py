import os
import numpy as np
import nibabel as nib
import pandas as pd
from nilearn.input_data import NiftiMasker
from nilearn.connectome import ConnectivityMeasure
import bct


def threshold_proportional_and_binarize(matrix, proportion):
    """
    Thresholds the connectivity matrix by retaining a given proportion of the strongest connections and binarizes the result.

    Parameters:
    matrix (np.ndarray): The connectivity matrix.
    proportion (float): The proportion of strongest connections to retain (between 0 and 1).

    Returns:
    np.ndarray: The thresholded and binarized connectivity matrix.
    """
    if not (0 < proportion <= 1):
        raise ValueError("Proportion must be between 0 and 1")

    # Flatten the matrix and sort all the values in descending order
    flattened = matrix.flatten()
    sorted_values = np.sort(flattened)[::-1]

    # Determine the threshold value for the top `proportion` connections
    threshold_index = int(len(sorted_values) * proportion)
    threshold_value = sorted_values[threshold_index - 1] if threshold_index > 0 else sorted_values[0]

    # Apply the threshold to the matrix and binarize it
    binary_matrix = (matrix >= threshold_value).astype(int)

    return binary_matrix


# Define the folder containing the mask image
mask_img_path = '/Users/data_processing/Desktop/T1W_McGill/Average_GM_image_res-4_thr-32.nii.gz'

# Load the mask image
mask_img = nib.load(mask_img_path)

# Initialize the NiftiMasker with the mask
masker = NiftiMasker(mask_img=mask_img)

# Initialize the ConnectivityMeasure
connectivity_measure = ConnectivityMeasure(kind='correlation')
corr_df = pd.DataFrame()
dc_df = pd.DataFrame()
Bin_thr = .5

# Load the BOLD images
directory_path = '/Users/data_processing/Desktop/McGil/fmriprep'
directory_contents = os.listdir(directory_path)
directories = [item for item in directory_contents if
               os.path.isdir(os.path.join(directory_path, item)) and item.startswith("su")]
# for bold_file in bold_files:
for directory in directories:

    bold_path = f"/Users/data_processing/Desktop/McGil/fmriprep/{directory}/func/{directory}_task-rest_run-3_space-MNI152NLin2009cAsym-preproc_bold_denoised_res-4.nii.gz"
    if os.path.exists(bold_path):
        # print(directory)
        bold_img = nib.load(bold_path)

        # Apply the mask and extract the time series
        time_series = masker.fit_transform(bold_img)

        # Calculate the functional connectivity matrix
        # corr_df[directory] = [connectivity_measure.fit_transform([time_series])[0]] 6G each subject

        correlation_matrix=connectivity_measure.fit_transform([time_series])[0]
        # print(len(correlation_matrix))  # Len 40498(res-3)->18345 res 4
    # # Calculate Degree Count (DC) using bct.degrees_und
        dc_df[directory] = [bct.degrees_und(threshold_proportional_and_binarize(np.array(correlation_matrix), Bin_thr))]

# save FC and DC
# corr_df.to_pickle('subs_corr_ses-1.pkl')
dc_df.to_pickle('subs_dc_ses-3.pkl')
