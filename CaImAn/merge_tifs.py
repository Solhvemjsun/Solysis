import sys
import os
import tifffile
import numpy as np
from glob import glob
import re

def natural_sort_key(path):
    """Sort paths by extracting embedded numbers."""
    name = os.path.basename(path)
    numbers = re.findall(r'\d+', name)
    return [int(n) for n in numbers] if numbers else [0]

input_folder = sys.argv[1]
output_file = sys.argv[2]

tif_files = sorted(glob(os.path.join(input_folder, '*.tif')), key=natural_sort_key)

all_frames = []
for tif_path in tif_files:
    data = tifffile.imread(tif_path)
    if data.ndim == 2:
        data = data[np.newaxis, ...]
    elif data.ndim != 3:
        raise ValueError(f"{tif_path} has invalid shape: {data.shape}")
    all_frames.append(data)
    print(f"Loaded {os.path.basename(tif_path)} with shape {data.shape}")

stacked = np.concatenate(all_frames, axis=0)
print(f"Final shape: {stacked.shape}")
tifffile.imwrite(output_file, stacked)
