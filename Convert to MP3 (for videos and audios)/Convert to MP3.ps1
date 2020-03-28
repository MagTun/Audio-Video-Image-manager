# you need to add this to registry (just click on the file)
# C:\Users\Me\Desktop\petit_program\PowerShell\PowerShell_script\tuto registry (add context menu...).reg

# To debug: go to the registry and change the args to CMD.EXE /K  ● ● 


# Improvment needed: 
# urgent:  set filename to title (they should be the same)
# all in one single cmd windows





#*******************Get info on the File
# Get the File from the path and retrieve var need for pffmpeg
# the args is sent by the  %1 argument in the command in  registry

$FilePath = dir -LiteralPath $args  #create dir/file object from a path as a string     //   -LiteralPath needed to handle strange symbols like [] in path 
Write-Host "FilePath: " $FilePath   # print full path
$DirectoryPath = $FilePath.Directory 
$file_name_complete = $FilePath.Name   # get filename
$fileNameOnly = $FilePath.BaseName   # get filename without extension
# $fileExtensionOnly = $FilePath.Extension #get extension only

# create the output folder  
$OutputFolder = Join-Path $DirectoryPath "audio files" #just the path (not created yet)
Write-Host "OutputFolder: " $OutputFolder   # print dir ● 

# create OutputFolder if not exist
New-Item -ItemType Directory -Force -Path $OutputFolder 


#************************ convert mp4 to mp3
# ffmpeg docs: https://www.ffmpeg.org/ffmpeg.html 

# syntax: ffmpeg -i filename.mp4 filename.mp3
# # save in  same  folder 
# ffmpeg -i $file_name_complete $DirectoryPath\$fileNameOnly".mp3"
# save in  output folder  - to use : uncomment part above 
ffmpeg -i $file_name_complete $OutputFolder\$fileNameOnly".mp3"



