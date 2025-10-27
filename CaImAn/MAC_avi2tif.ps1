$PY = "/opt/homebrew/Caskroom/miniforge/base/envs/dashboard_env/bin/python"
# ---- paths (relative to this script folder) ----
$ROOT = $PSScriptRoot
$input_folder       = Join-Path $ROOT "data/msCam_avi_path"
$output_folder      = Join-Path $ROOT "data/msCam_tif_path"
$temp_frame_folder  = Join-Path $ROOT "data/temp_frames"

# ---- ensure dirs exist (use PowerShell cmdlet, not /bin/mkdir) ----
foreach ($p in @($output_folder, $temp_frame_folder)) {
    if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

# ---- loop over avi files ----
Get-ChildItem -Path $input_folder -Filter *.avi | ForEach-Object {
    $input = $_.FullName
    $basename = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

    $frame_subfolder = Join-Path $temp_frame_folder $basename
    if (-not (Test-Path $frame_subfolder)) { New-Item -ItemType Directory -Path $frame_subfolder -Force | Out-Null }

    # extract frames to gray tifs
    ffmpeg -y -i $input -vf "format=gray" (Join-Path $frame_subfolder "frame_%05d.tif")

    # merge frames into one tif
    $out_tif = Join-Path $output_folder "$basename.tif"
    & $PY merge_tifs.py $frame_subfolder $out_tif
    Write-Host "Saved $basename.tif"
}

# ---- merge all single tifs into one big stack (optional) ----
Write-Host "`nMerging all .tif files into a big stack..."
$final_out = Join-Path $output_folder "merged_all.tif"
& $PY merge_tifs.py $output_folder $final_out
Write-Host "Final merged file saved to: $final_out"
