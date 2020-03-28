
# ============================================================== ¤ INFO
# compress /resize photo 
# ffmpeg will NOT ask for confirmation to overwrite file if it exist

# you need to add this to registry (just click on the .reg file)


# ============================================================== ¤ Get info from the file 
# Get the File from the path and retrieve var need for pffmpeg
# the args is sent by the  %1 argument in the command in  registry

# $args = "C:\Users\Me\Desktop\test_powershell"  # ●

$FilePath = $args[0]  

Set-Location -Path $FilePath

Write-Host "FilePath: " $FilePath   # print full path 


# ============================================================== ¤  Form 
Add-Type -AssemblyName System.Windows.Forms

$global:resolution = 0

# Create main Form 
$form = New-Object System.Windows.Forms.Form
$form.Font = "Comic Sans MS,8.25"
$form.Text = "Trim $file_name_complete "
$form.Size = "450,240"
# $form.Topmost = $true



# ------------------------------------------------------ ¤¤ info label
# create a label with filename 
$FolderLabel = New-Object System.Windows.Forms.Label 
$FolderLabel.Location = "5, 5"
$FolderLabel.Size = "480, 20"
$FolderLabel.Text = "Folder :  $FilePath  "
$form.Controls.Add($FolderLabel)


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

# ------------------------------------------------------ ¤¤ new resolution 

# Create a text box and label for new height
$newresolutionLabel = New-Object System.Windows.Forms.Label 
$newresolutionLabel.Location = "5, 73"
$newresolutionLabel.Size = "145, 20"
$newresolutionLabel.Text = "Decrease resolution (2-5):"
$form.Controls.Add($newresolutionLabel)
$newresolutionTextBox = New-Object System.Windows.Forms.TextBox
$newresolutionTextBox.Location = "200, 70"
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

  
        dir *.* | foreach-object {
            $newname = $_.Name.Remove($_.Name.Length - $_.Extension.Length) + "_" + $resolutionint + ".jpg"
            Write-Host $newname
            # resize the picture  -y = overwrite file without askin confirmation
            # ffmpeg -y -i $file_name_complete -qscale:v ${resolutionint} $DirectoryPath\$fileNameOnly"_"$resolutionint$fileExtensionOnly
            # ffmpeg -y -i "$_" -qscale:v 50 $newname 
            ffmpeg -y -i "$_" -qscale:v $resolutionint $newname
        }
        
        
        # info label then start timer to clear the info label
        $InfoLabel.Text = "File saved !"
        $Timer.Start()

    } 
    Catch {  
    }

}

Function ClearBox {
    $newresolutionTextBox.Text = ""

}




# ...................................... ¤¤¤  the buttons

# Change resolution Button 
$TrimButton = New-Object System.Windows.Forms.Button 
$TrimButton.Location = "5,100"
$TrimButton.Size = "150,23"
$TrimButton.Text = " Save with new resolution"
$TrimButton.add_Click( { changeresolution })
$form.Controls.Add($TrimButton)

# Clear  Button 
$ClearButton = New-Object System.Windows.Forms.Button 
$ClearButton.Location = "5 ,130"
$ClearButton.Size = "60,23"
$ClearButton.Text = "Clear All"
$ClearButton.add_Click( { ClearBox })
$form.Controls.Add($ClearButton)

# ============================================================== ¤ Launch the forms
# set the box with the cursor 
$form.Add_Shown( { $newresolutionTextBox.Select() })
$form.ShowDialog()







