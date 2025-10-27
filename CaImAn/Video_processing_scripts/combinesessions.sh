# Combine the splited pictures in one file
# magick convert msCam_*.tif -compress none msCam.tif
# magick 'msCam_*.tif' -compress none TIFF64:msCrossSession.tif
magick -limit thread 16 'msCam_*.tif' -compress none TIFF64:msCrossSession.tif
# Clean up
# rm  msCam_*.tif
