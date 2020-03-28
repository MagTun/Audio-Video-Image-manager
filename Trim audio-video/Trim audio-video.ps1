

# ============================================================== ¤ INFO
# trim audio or video file by settign the start time and the end time
# ffmpeg will NOT ask for confirmation to overwrite file if it exist

# you need to add this to registry (just click on the .reg file)




#  should also ask to inly reduce the bitrate of video
# ffmpeg -i <inputfilename> -s 640x480 -b:v 512k -vcodec mpeg1video -acodec copy <outputfilename>  https://stackoverflow.com/a/4491369/3154274
# ffmpeg -i input.mp4 -vcodec libx265 -crf 20 output.mp4  https://unix.stackexchange.com/a/38380  (18-24)



# ============================================================== ¤ Get info from the file 
# Get the File from the path and retrieve var need for pffmpeg
# the args is sent by the  %1 argument in the command in  registry

$FilePath = dir -LiteralPath $args  #create dir/file object from a path as a string     //   -LiteralPath needed to handle strange symbols like [] in path  
# $FilePath = dir -LiteralPath "T:\Music\Armand Amar - Iranna2.mp4"  # ●
Write-Host "FilePath: " $FilePath   # print full path 
$DirectoryPath = $FilePath.Directory  # get parent folder
$file_name_complete = $FilePath.Name   # get filename
$fileNameOnly = $FilePath.BaseName   # get filename without extension
$fileExtensionOnly = $FilePath.Extension #get extension only 



# needed for vscode 
Set-Location -Path $DirectoryPath 

# get waveform 
# https://trac.ffmpeg.org/wiki/Waveform
# ffmpeg -i  $file_name_complete -filter_complex "aformat=channel_layouts=mono,showwavespic=s=640x120" -frames:v 1 $DirectoryPath\"output.png" -y
ffmpeg -i  $file_name_complete -filter_complex "showwavespic=s=640x120" -frames:v 1 $DirectoryPath\"output.png" -y
$FilepathForWaveform = dir -LiteralPath $DirectoryPath\"output.png"

# get lenght of file    (ffprobe is part of ffmpeg)
$duration_full = ffprobe -i $file_name_complete -show_entries format=duration -v quiet -of csv="p=0"  #  -sexagesimal  : this option give the time  in hh:mm:ss.ms instead of default = sec 

#  convert time to human readable
Write-Host "¤¤¤Duration: " $duration_full
$duration_integer = [int]$duration_full   
Write-Host "¤¤¤Duration int : " $duration_integer
$duration_min_sec = [timespan]::fromseconds($duration_integer)
$duration_min_sec.ToString("hh\:mm\:ss")
# get hours, mins, secs : https://stackoverflow.com/q/21842175/3154274
Write-Host "$($duration_min_sec.hours):$($duration_min_sec.minutes):$($duration_min_sec.seconds),$($duration_min_sec.milliseconds)"

# ============================================================== ¤  Form 
Add-Type -AssemblyName System.Windows.Forms

# $global:minStart = 0
# $global:secStart = 0
# $global:minEnd = $duration_min_sec.hours*60+$duration_min_sec.minutes
# $global:secEnd = $duration_min_sec.seconds

# Create main Form 
$form = New-Object System.Windows.Forms.Form
$form.Font = "Comic Sans MS,8.25"
$form.Text = "Trim $file_name_complete "
$form.Size = "700,350"
# $form.Size = "450,225"
# $form.Topmost = $true



# ------------------------------------------------------ ¤¤ info label
# create a label with filename 
$FilenameLabel = New-Object System.Windows.Forms.Label 
$FilenameLabel.Location = "5, 5"
$FilenameLabel.Size = "480, 20"
$FilenameLabel.Text = "Filename :  $file_name_complete  "
$form.Controls.Add($FilenameLabel)

# create a label with duration 
$DurationLabel = New-Object System.Windows.Forms.Label 
$DurationLabel.Location = "5, 25"
$DurationLabel.Size = "200, 20"
$DurationLabel.Text = "File Duration :  $duration_min_sec "
$form.Controls.Add($DurationLabel)

# create a label with Info 
$InfoLabel = New-Object System.Windows.Forms.Label 
$InfoLabel.Location = "170, 50"
$InfoLabel.Size = "100, 50"
# $InfoLabel.Multiline = $True
$InfoLabel.Text = ""
$form.Controls.Add($InfoLabel)

# create a label with warning 
$WarningLabel = New-Object System.Windows.Forms.Label 
$WarningLabel.Location = "150, 150"
$WarningLabel.Size = "250, 70"
$WarningLabel.Text = "Output file = ...filename_trimmed... - If output file already exist, it will be overwritten - Convert Hours in min: ex trim from 59m to 90m"
$form.Controls.Add($WarningLabel)




# ------------------------------------------------------ ¤¤ Start time 
# create a label "start time" 
$StartLabel = New-Object System.Windows.Forms.Label 
$StartLabel.Location = "5, 45"
$StartLabel.Size = "150, 20"
$StartLabel.Text = "Start new file at:"
$form.Controls.Add($StartLabel)


# Create a text box and label for Start min 
$minStartTextBox = New-Object System.Windows.Forms.TextBox
$minStartTextBox.Location = "10, 65"
$minStartTextBox.Size = "30, 20"
$minStartTextBox.Text = 0
$form.Controls.Add($minStartTextBox)
$minStartLabel = New-Object System.Windows.Forms.Label 
$minStartLabel.Location = "40, 73"
$minStartLabel.Size = "30, 20"
$minStartLabel.Text = "Min"
$form.Controls.Add($minStartLabel)


# Create a text box and label for Start sec
$secStartTextBox = New-Object System.Windows.Forms.TextBox
$secStartTextBox.Location = "80, 65"
$secStartTextBox.Size = "30, 20"
$secStartTextBox.Text = 0
$form.Controls.Add($secStartTextBox)
$secStartLabel = New-Object System.Windows.Forms.Label 
$secStartLabel.Location = "110, 73"
$secStartLabel.Size = "30, 20"
$secStartLabel.Text = "Sec"
$form.Controls.Add($secStartLabel)


# ------------------------------------------------------ ¤¤ End  time
# create a label "end time" 
$EndLabel = New-Object System.Windows.Forms.Label 
$EndLabel.Location = "5, 95"
$EndLabel.Size = "150, 20"
$EndLabel.Text = "End new file at:"
$form.Controls.Add($EndLabel)


# Create a text box and label for end min 
$minEndTextBox = New-Object System.Windows.Forms.TextBox
$minEndTextBox.Location = "10, 115"
$minEndTextBox.Size = "30, 20"
$minEndTextBox.Text = $duration_min_sec.hours*60+$duration_min_sec.minutes
$form.Controls.Add($minEndTextBox)
$minEndLabel = New-Object System.Windows.Forms.Label 
$minEndLabel.Location = "40, 123"
$minEndLabel.Size = "30, 20"
$minEndLabel.Text = "Min"
$form.Controls.Add($minEndLabel)


# Create a text box and label for end sec
$secEndTextBox = New-Object System.Windows.Forms.TextBox
$secEndTextBox.Location = "80, 115"
$secEndTextBox.Size = "30, 20"
$secEndTextBox.Text = $duration_min_sec.seconds
$form.Controls.Add($secEndTextBox)
$secEndLabel = New-Object System.Windows.Forms.Label 
$secEndLabel.Location = "110, 123"
$secEndLabel.Size = "30, 20"
$secEndLabel.Text = "Sec"
$form.Controls.Add($secEndLabel)


# ------------------------------------------------------ ¤¤ info label
Function Timer_Tick() {
    $InfoLabelSaved.Text = ""
    $timer.Enabled = $false
}


$Timer = New-Object System.Windows.Forms.Timer
$Timer.Interval = 3000
$Timer.Add_Tick( { Timer_Tick })


# create an info lable to say when the file is saved" 
$InfoLabelSaved = New-Object System.Windows.Forms.Label 
$InfoLabelSaved.Location = "15, 180"
$InfoLabelSaved.Size = "150, 20"
$InfoLabelSaved.Text = "...."
$form.Controls.Add($InfoLabelSaved)



# ------------------------------------------------------ ¤¤ Button : first function then button form

# ...................................... ¤¤¤  functions for the buttons (they needed to be above the button)
# Print the Tone
Function Trim {

    # Write-Host  $minStartTextBox.Text
    # Write-Host  $secStartTextBox.Text
    # Write-Host  $minEndTextBox.Text
    # Write-Host  $secEndTextBox.Text

    # if empty set value to 0 

    Try { 
        # clear info label
        $InfoLabel.Text = ""  
        $InfoLabelSaved.Text = ""  

        #  verify that all texbox are filled


        if (($minStartTextBox.Text -eq "") -OR ($secStartTextBox.Text -eq "") -OR ($minEndTextBox.Text -eq "") -OR ($secEndTextBox.Text -eq "")  ) {
            $InfoLabel.Text = "Fill *all* the textboxes"
            throw ""
        }

        # .... * convert start/end time to sec
        $starttime = [int]$minStartTextBox.Text * 60 + [int]$secStartTextBox.Text
        $endtime = [int]$minEndTextBox.Text * 60 + [int]$secEndTextBox.Text
       
       
        # verify that the startime and endtime won't create an error in ffmpeg
        if ($starttime -gt $endtime) {
            $InfoLabel.Text = "Start time can't be superior to End time"
            throw ""
        } 

        if ($starttime -eq $endtime) {
            $InfoLabel.Text = "Start time can't be egal to End time"
            throw ""
        }

        # close form and new pop up
        # $form.Close()
        # Remove-Item -Path $FilepathForWaveform -Force

        # # cut file  the output folder -  create OutputFolder if not exist   -y = overwrite file without askin confirmation
        ffmpeg -y  -ss $starttime -to $endtime -i $file_name_complete $DirectoryPath\$fileNameOnly"_trimmed"$fileExtensionOnly 

        # info label then start timer to clear the info label
        $InfoLabelSaved.Text = "File saved !"
        $Timer.Start()

    } 
    Catch { 

        
    }

}

Function ClearBox {

    $minEndTextBox.Text = ""
    $secEndTextBox.Text = ""
    $secStartTextBox.Text = ""
    $minStartTextBox.Text = ""

}




# ...................................... ¤¤¤  Trim + Clear All buttons


# Clear  Button 
$ClearButton = New-Object System.Windows.Forms.Button 
$ClearButton.Location = "5 ,150"
$ClearButton.Size = "60,23"
$ClearButton.Text = "Clear All"
$ClearButton.add_Click( { ClearBox })
$form.Controls.Add($ClearButton)
 
# Trim Button 
$TrimButton = New-Object System.Windows.Forms.Button 
$TrimButton.Location = "75,150"
$TrimButton.Size = "65,23"
$TrimButton.Text = "Trim"
$TrimButton.add_Click( { Trim })
$form.Controls.Add($TrimButton)





# ------------------------------------------------------ ¤¤ waveform
# $Image = [system.drawing.image]::FromFile("$PSScriptRoot\script runner.png") 
# $Picture = (get-item ($FilepathForWaveform))
$img = [System.Drawing.Image]::Fromfile($FilepathForWaveform)
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Width = $img.Size.Width
$pictureBox.Height = $img.Size.Height
$pictureBox.Image = $img
$pictureBox.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
$pictureBox.Location = "15, 200"
# $pictureBox.Location = New-object System.Drawing.Size($form.bottom + 10, $form.right + 10)
$form.controls.add($pictureBox)

# ============================================================== ¤ Launch the forms
# set the box with the cursor 
$form.Add_Shown( { $minEndTextBox.Select() })
$form.ShowDialog()

