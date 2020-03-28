

# you need to add this to registry (just click on the .reg file )

# Improvment needed: 
# urgent:  set filename to title (they should be the same)
# all in one single cmd windows



#*******************Get info on the File
# Get the File from the path and retrieve var need for pffmpeg
# the args is sent by the  %1 argument in the command in  registry

$FilePath = dir -LiteralPath $args  #create dir/file object from a path as a string     //   -LiteralPath needed to handle strange symbols like [] in path 
Write-Host "FilePath: " $FilePath   # print full path 
$DirectoryPath = $FilePath.Directory  # get parent folder
$file_name_complete = $FilePath.Name   # get filename
$fileNameOnly = $FilePath.BaseName   # get filename without extension
$fileExtensionOnly = $FilePath.Extension #get extension only 


# create the output folder -  create OutputFolder if not exist
$OutputFolder = Join-Path $DirectoryPath $fileExtensionOnly #just the path (not created yet)
New-Item -ItemType Directory -Force -Path $OutputFolder 



#************************ split audio in chunk (when tag finished: at the end delete $file_name_complete)
# ffmpeg docs: https://www.ffmpeg.org/ffmpeg.html 
# add metadata : https://wiki.multimedia.cx/index.php/FFmpeg_Metadata

ffmpeg -i $file_name_complete   -f segment -segment_time 300 -c copy $OutputFolder\$fileNameOnly"_"%03d$fileExtensionOnly  

# -f Force input or output file format. The format is normally auto detected for input files and guessed from the file extension for output files, so this option is not needed in most cases.
# %03d = 001, 002...
# %02d = 01, 01 ...
# 1mn=60 (300=5mn)


#************************  set title for each newly created file 


# $wmp = new-object -comobject wmplayer.ocx

# # https://groups.google.com/forum/#!topic/microsoft.public.windows.powershell/QgHc8HFJVfw
# # https://techibee.com/powershell/change-the-track-name-of-music-files-using-powershell/441
# foreach ($f in dir $OutputFolder) {
#     $filename = $f.BaseName
#     $media = $wmp.newMedia($f)
#     # Write-host $media.title
#     $media.name = "foo"
#     # $media.name = "$filename"
# }



# # https://groups.google.com/forum/#!topic/microsoft.public.windows.powershell/QgHc8HFJVfw
# foreach ($f in dir $OutputFolder) {
#     $f
#     $media = $wmp.newMedia($f)
#     # $media.name = "foo"
#     $media | ft sourceURL, name
# }













# ------------try:
# ask question https://github.com/FFmpeg/FFmpeg 
#  newname=${file:0:-4}_2 ext=${file##*.} filename=${file} showname=${file%% *} episode=${file:9:3} nameext=${file##*- } title=${nameext%.*};     ffmpeg -i "$filename" -metadata title="$title" -metadata track=$episode -metadata album=$showname -c copy "$newname.$ext";    mv -f "$newname.$ext" "$filename";    done

#  for f in *.AVI;
# do echo “Processing $f”
# ffmpeg -i “$f” -map_metadata 0 -vcodec libx264 -preset veryslow -crf 22 -acodec libmp3lame -aq 4 “${f%.AVI}.mkv”


  
# ffmpeg -i $file_name_complete -f segment -segment_time 300 -metadata "title=`"${fileNameOnly}_%03d`"" -c copy "${fileNameOnly}_%03d${fileExtensionOnly}"



# Try -metadata "title=${fileNameOnly}_%03d" or -metadata "title=`"${fileNameOnly}_%03d`"". Also, if you want to wrap a commandline across multiple lines you must escape the line break with a backtick.


# -metadata title="$Title" -c copy -map 0 "$nF"






# runing the code silently: https://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed




# # Param([String]$FileNameSelected)
# # Write-Verbose $FileNameSelected


# add the required .NET assembly:
# Add-Type -AssemblyName System.Windows.Forms
# # show the MsgBox:
# $result = [System.Windows.Forms.MessageBox]::Show('Do you want to restart?', 'Warning', 'YesNo', 'Warning')

# # check the result:
# if ($result -eq 'Yes') {
#     Restart-Computer -WhatIf
# }
# else {
#     Write-Warning 'Skipping Restart'
# }
