import os
import nibabel as nib
import numpy as np


# def load_nifti_image(file_path):
#     """Load a NIfTI image and return the image data as a numpy array."""
#     img = nib.load(file_path)
#     return img.get_fdata(), img.affine, img.header


def average_3D_nifti_images(img_files):
    """Calculate the average of multiple 3D NIfTI images."""
    n_images = len(img_files)
    if n_images == 0:
        raise ValueError("No images provided for averaging.")

    # Load the first image to get the shape and initialize the sum array
    data, affine, header=img_files[0].get_fdata(), img_files[0].affine, img_files[0].header
    sum_data = np.zeros_like(data)

    # Sum all the images
    for file in img_files:
        data = file.get_fdata()
        sum_data += data

    # Calculate the average
    avg_data = sum_data / n_images

    return avg_data, affine, header


def save_nifti_image(data, affine, header, output_path):
    """Save the given data as a NIfTI image."""
    avg_img = nib.Nifti1Image(data, affine, header)
    nib.save(avg_img, output_path)


# Define the folder containing the NIfTI images
directory_path = '/Users/data_processing/Desktop/T1W_McGill'
output_file = '/Users/data_processing/Desktop/T1W_McGill/average_GM_image.nii.gz'
img_files=[]
# Get all NIfTI files in the folder
directory_contents = os.listdir(directory_path)
directories = [item for item in directory_contents if
    os.path.isdir(os.path.join(directory_path, item)) and item.startswith("su")]
for directory in directories:
    print(directory)
    GM_file = f"/Users/data_processing/Desktop/T1W_McGill/{directory}/anat/{directory}_space-MNI152NLin2009cAsym_label-GM_probseg.nii.gz"
    if os.path.exists(GM_file):
        img_files.append(nib.load(GM_file))

# image_files = [os.path.join(image_folder, f) for f in os.listdir(image_folder) if
#                f.endswith('.nii') or f.endswith('.nii.gz')]
# Calculate the average
avg_data, affine, header = average_3D_nifti_images(img_files)

# Save the average image
save_nifti_image(avg_data, affine, header, output_file)

print(f"Saved the average image to {output_file}")






