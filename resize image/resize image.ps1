
# ============================================================== ¤ INFO
# compress /resize photo 
# ffmpeg will NOT ask for confirmation to overwrite file if it exist

# you need to add this to registry (just click on the .reg file)




# ============================================================== ¤ Get info from the file 
# Get the File from the path and retrieve var need for pffmpeg
# the args is sent by the  %1 argument in the command in  registry

# $args = "C:\Users\Me\Desktop\test_powershell\20190628_174111.jpg"  # ●

$FilePath = dir -LiteralPath $args  #create dir/file object from a path as a string     //   -LiteralPath needed to handle strange symbols like [] in path 
Write-Host "FilePath: " $FilePath   # print full path 
$DirectoryPath = $FilePath.Directory  # get parent folder
$file_name_complete = $FilePath.Name   # get filename
$fileNameOnly = $FilePath.BaseName   # get filename without extension
$fileExtensionOnly = $FilePath.Extension #get extension only 

# needed for vscode 
Set-Location -Path $DirectoryPath 


# get height and width of file    (ffprobe is part of ffmpeg)
# https://stackoverflow.com/a/27831698/3154274
$all = ffprobe -i $file_name_complete -show_entries  stream
# cf https://github.com/eugeneware/ffprobe
$width = ffprobe -i $file_name_complete -show_entries stream=width -v quiet -of csv="p=0"
$height = ffprobe -i $file_name_complete -show_entries stream=height -v quiet -of csv="p=0"

# Write-Host "all: " $all
Write-Host "width: " $width
Write-Host "height: " $height
Write-Host "all: " $all


# get size and format it to the corresponding unit
# $size = (Get-Item $file_name_complete).Length / 1MB
Function Format-FileSize() {
    Param ([int]$size)
    If ($size -gt 1TB) { [string]::Format("{0:0.00} TB", $size / 1TB) }
    ElseIf ($size -gt 1GB) { [string]::Format("{0:0.00} GB", $size / 1GB) }
    ElseIf ($size -gt 1MB) { [string]::Format("{0:0.00} MB", $size / 1MB) }
    ElseIf ($size -gt 1KB) { [string]::Format("{0:0.00} kB", $size / 1KB) }
    ElseIf ($size -gt 0) { [string]::Format("{0:0.00} B", $size) }
    Else { "" }
}
$size = Format-FileSize((Get-Item $file_name_complete).length)

Write-Host "size: " $size




# ============================================================== ¤  Form 
Add-Type -AssemblyName System.Windows.Forms

$global:widthoutput = 0
$global:heightoutput = 0
$global:resolution = 0

# Create main Form 
$form = New-Object System.Windows.Forms.Form
$form.Font = "Comic Sans MS,8.25"
$form.Text = "Trim $file_name_complete "
$form.Size = "450,240"
# $form.Topmost = $true



# ------------------------------------------------------ ¤¤ info label
# create a label with filename 
$FilenameLabel = New-Object System.Windows.Forms.Label 
$FilenameLabel.Location = "5, 5"
$FilenameLabel.Size = "480, 20"
$FilenameLabel.Text = "Filename :  $file_name_complete  "
$form.Controls.Add($FilenameLabel)

# create a label with width and height  
$width_heightLabel = New-Object System.Windows.Forms.Label 
$width_heightLabel.Location = "5, 25"
$width_heightLabel.Size = "200, 20"
$width_heightLabel.Text = "Width x Height =  $width x $height "
$form.Controls.Add($width_heightLabel)

# create a label with width and height  
$sizetLabel = New-Object System.Windows.Forms.Label 
$sizetLabel.Location = "205, 25"
$sizetLabel.Size = "200, 20"
$sizetLabel.Text = "size =  $size "
$form.Controls.Add($sizetLabel)


# create a label with Info 
$InfoLabel = New-Object System.Windows.Forms.Label 
$InfoLabel.Location = "5, 153"
$InfoLabel.Size = "500, 20"
# $InfoLabel.Multiline = $True
$InfoLabel.Text = "     "
$form.Controls.Add($InfoLabel)

# create a label with warning 
$WarningLabel = New-Object System.Windows.Forms.Label 
$WarningLabel.Location = "5, 180"
$WarningLabel.Size = "500, 500"
$WarningLabel.Text = "This will save the file as filename_modif - overwrite confirmation removed"
$form.Controls.Add($WarningLabel)



 
# ------------------------------------------------------ ¤¤ new size time 
# creare a label "start time" 
$newsizeLabel = New-Object System.Windows.Forms.Label 
$newsizeLabel.Location = "5, 50"
$newsizeLabel.Size = "250, 20"
$newsizeLabel.Text = "New size (empty or -1 = keep aspect ratio):"
$form.Controls.Add($newsizeLabel)


# Create a text box and label for new width 
$newwidthtLabel = New-Object System.Windows.Forms.Label 
$newwidthtLabel.Location = "5, 73"
$newwidthtLabel.Size = "40, 20"
$newwidthtLabel.Text = "width:"
$form.Controls.Add($newwidthtLabel)
$newwidthTextBox = New-Object System.Windows.Forms.TextBox
$newwidthTextBox.Location = "45, 70"
$newwidthTextBox.Size = "35, 20"
$newwidthTextBox.Text = ""
$form.Controls.Add($newwidthTextBox)



# Create a text box and label for new height
$newheightLabel = New-Object System.Windows.Forms.Label 
$newheightLabel.Location = "85, 73"
$newheightLabel.Size = "55, 20"
$newheightLabel.Text = "x height:"
$form.Controls.Add($newheightLabel)
$newheightTextBox = New-Object System.Windows.Forms.TextBox
$newheightTextBox.Location = "145, 70"
$newheightTextBox.Size = "40, 20"
$newheightTextBox.Text = ""
$form.Controls.Add($newheightTextBox)


# ------------------------------------------------------ ¤¤ new resolution 

# Create a text box and label for new height
$newresolutionLabel = New-Object System.Windows.Forms.Label 
$newresolutionLabel.Location = "250, 73"
$newresolutionLabel.Size = "145, 20"
$newresolutionLabel.Text = "Decrease resolution (2-5):"
$form.Controls.Add($newresolutionLabel)
$newresolutionTextBox = New-Object System.Windows.Forms.TextBox
$newresolutionTextBox.Location = "400, 70"
$newresolutionTextBox.Size = "30, 20"
$newresolutionTextBox.Text = 5
$form.Controls.Add($newresolutionTextBox)




# ------------------------------------------------------ ¤¤ timer for labelInfo
Function Timer_Tick() {
    $InfoLabel.Text = ""
    $timer.Enabled = $false
}


$Timer = New-Object System.Windows.Forms.Timer
$Timer.Interval = 3000
$Timer.Add_Tick( { Timer_Tick })



# ------------------------------------------------------ ¤¤ Button

# ...................................... ¤¤¤  functions for the buttons (they needed to be above the button)


# do the same for the resolution -- 
# add the -1 for empty width/size to keep ration


# Function emptyInfoLabelafter3sec {
#     $CountDown = 5
#     $Timer = New-Object System.Windows.Forms.Timer
#     $Timer.Interval = 1000
#     $Timer.Add_Tick( { Timer_Tick })
#     $Timer.Start()
    

# }

Function changesize {
    Try { 
        # clear info label
        $InfoLabel.Text = ""  

        #  verify that all texbox are filled
        if (($newwidthTextBox.Text -eq "") -AND ($newheightTextBox.Text -eq "")) {
            $InfoLabel.Text = "Fill the *width* and *height* textboxes"
            throw ""
        }
        if ($newwidthTextBox.Text -eq "") {
            $newwidthTextBox.Text = -1
        }

        if ($newheightTextBox.Text -eq "") {
            $newheightTextBox.Text = -1
        }
        # .... * convert start/end time to sec
        $widthint = [int]$newwidthTextBox.Text
        $heightint = [int]$newheightTextBox.Text
       


        # close form and new pop up
        # $form.Close()

        # # resize the picture  -y = overwrite file without askin confirmation
        ffmpeg -y -i $file_name_complete -vf scale=${widthint}:${heightint} $DirectoryPath\$fileNameOnly"_"$widthint"x"$heightint$fileExtensionOnly

        # info label then start timer to clear the info label
        $InfoLabel.Text = "File saved !"
        $Timer.Start()

    } 
    Catch { 

    }

}


Function changeresolution {


    Try { 
        # clear info label
        $InfoLabel.Text = ""  

        #  verify that all texbox are filled
        if ($newresolutionTextBox.Text -eq "") {
            $InfoLabel.Text = "Fill the *resolution* textbox"
            throw ""
        }

        # .... * convert start/end time to sec
        $resolutionint = [int]$newresolutionTextBox.Text


        # resize the picture  -y = overwrite file without askin confirmation
        ffmpeg -y -i $file_name_complete -qscale:v ${resolutionint} $DirectoryPath\$fileNameOnly"_"$resolutionint$fileExtensionOnly

        # info label then start timer to clear the info label
        $InfoLabel.Text = "File saved !"
        $Timer.Start()

    } 
    Catch {  
    }

}

Function ClearBox {
    $newwidthTextBox.Text = ""
    $newheightTextBox.Text = ""
    $newresolutionTextBox.Text = ""

}




# ...................................... ¤¤¤  the buttons

# Change Size Button 
$TrimButton = New-Object System.Windows.Forms.Button 
$TrimButton.Location = "5,100"
$TrimButton.Size = "150,23"
$TrimButton.Text = "Save with new Size"
$TrimButton.add_Click( { changesize })
$form.Controls.Add($TrimButton)


# Change resolution Button 
$TrimButton = New-Object System.Windows.Forms.Button 
$TrimButton.Location = "250,100"
$TrimButton.Size = "150,23"
$TrimButton.Text = " Save with new resolution"
$TrimButton.add_Click( { changeresolution })
$form.Controls.Add($TrimButton)

# Clear  Button 
$ClearButton = New-Object System.Windows.Forms.Button 
$ClearButton.Location = "150 ,130"
$ClearButton.Size = "60,23"
$ClearButton.Text = "Clear All"
$ClearButton.add_Click( { ClearBox })
$form.Controls.Add($ClearButton)

# ============================================================== ¤ Launch the forms
# set the box with the cursor 
$form.Add_Shown( { $newwidthTextBox.Select() })
$form.ShowDialog()







