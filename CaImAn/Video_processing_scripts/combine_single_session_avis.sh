# Create list of videos in current folder
ls msCam*.avi | sort -V | sed "s/^/file '/;s/$/'/" > mylist.txt
# Combine the videos
ffmpeg -f concat -safe 0 -i mylist.txt -c copy msCombined.avi
# Split the combined video into .tif pictures
ffmpeg -i msCombined.avi -vsync 0 msCam_%05d.tif
# Combine the splited pictures in one file
magick convert msCam_*.tif -compress none msCam.tif
# Clean up
rm  msCam_*.tif
