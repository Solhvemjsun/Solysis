# Video Processing and CaImAn Instrcution

This is [CaImAn Official Repo](https://github.com/flatironinstitute/CaImAn). Our CNMF-E model & algorithms pipeline is based on this.

## Overview
<pre>
  <code>
    📁 Project Root
      ├── README.md                
      ├── avi2tif.ps1                   # Run this to transform a series of avi into a single large tif (sorted)
      ├── demo_pipeline_cnmfE.ipynb     # Pipeline (Using cnmf-E to extract a hdf5 result from a single (N, 320, 320) tif file)
      ├── environment.yml / env.txt     # Environment for Video Processing and CaImAn Instrcution        
      ├── ffmpeg.exe
      ├── merge_tifs.py
      └── data              
            ├── msCam_avi_path          # Contains a series of avi file (input)
            ├── msCam_tif_path          # Contains a series of avi file (output)
            ├── temp_frames
            ├── msCam1_3D_pipeline_cnmfe_results.hdf5
            └── calcium_signals_30fps.csv
  </code>
</pre>

## Instrcution
0. Prepare and activate correct environment for CaImAn section (refer to <code>environment.yml</code> / <code>env.txt</code>).
1. Video Processing: Call <code>.\avi2tif.ps1</code>. It transforms a series of avi into a single large tif (sorted). You should prepare your avi files (e.g. <code>msCam1.avi</code>) in <code>msCam_avi_path</code> before running this. After that, we expect a tif file <code>merged_all.tif</code> in the <code>msCam_tif_path</code>.
2. CaImAn: Carefully run <code>demo_pipeline_cnmfE.ipynb</code> cell by cell. You should edit (hard code) some lines to make it work for you. We expect a <code>demo_pipeline_cnmfe_results.hdf5</code> will be avaliable in the folder as a result.
