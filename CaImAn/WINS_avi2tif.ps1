# avi2merged_tif.ps1

$input_folder = "./data/msCam_avi_path"
$msCam_tif_path = "./data/msCam_tif_path"
$temp_frames = "./data/temp_frames"
$final_merged_file = "./data/msCam_tif_path/merged_all.tif"

mkdir $output_folder -Force
mkdir $temp_frame_folder -Force

# Step 1-2: Process each AVI file
Get-ChildItem "$input_folder\*.avi" | ForEach-Object {
    $basename = $_.BaseName
    $input = $_.FullName
    $frame_subfolder = Join-Path $temp_frame_folder $basename
    mkdir $frame_subfolder -Force

    ffmpeg -y -i $input -vf format=gray (Join-Path $frame_subfolder "frame_%04d.tif")

    $out_tif = Join-Path $output_folder "$basename.tif"
    python merge_tifs.py $frame_subfolder $out_tif
    Write-Host "Saved $basename.tif"
}

# Step 3: Merge all multi-page .tif into one big .tif
Write-Host "`nMerging all .tif files into a big stack..."
python merge_tifs.py $output_folder $final_merged_file
Write-Host "Final merged file saved to: $final_merged_file"
