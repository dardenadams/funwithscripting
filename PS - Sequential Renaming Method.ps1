  # Method for renaming files with added numbers in the case of name conflicts.
# This problem occurs frequently if refiling large numbers of documents to a new
# location.
# - Puts sequential number after name and before extension (ex. 'name(1).txt').
#   This method is harder than putting it before (ex. '(1)name.txt') since the
#   extension must be removed, number added, then extension re-added.
Clear-Host

# We need several lists for this method:
# List of all paths (these will be just paths, not paths with names at the end)
$pathlist = @()
# List of names (separated from their paths)
$namelist = @()
# List of extensions
$extensionlist = @()

# Source and destination directories
$sourcedir = "D:\Scratch\folder"
$destinationdir = "D:\Scratch\destination"

# Ints for synchronizing between arrays and sequentially renaming identical files
$i = 0
$j = 1

# Now we get a list of the files in the source directory
Get-ChildItem $sourcedir -Recurse | Where-Object {$_.Attributes -ne 'Directory'} | ForEach-Object {

    # Get the extension, name, and then fullname (path+name) of each item
    $extension = ($_).Extension
    $name1 = ($_).Name
    $path1 = ($_).FullName
    
    # We have to remove the extension from the short names before adding them to the list
    $name2 = $name1.Replace($extension,"")    
    # We also have to remove the short name from the fullname before adding them to the list
    $path2 = $path1.Replace($name1,"")
    
    # Add all to lists
    $pathlist += $path2
    $namelist += $name2
    $extensionlist += $extension
}

# Iterate through each path and move each to destination
Foreach($path in $pathlist){
    # We have to now synchronize the path with its corresponding name and extension
    # using the method detailed in the script Parallel Synchronization
    $currentname = $namelist[$i]
    $currentextension = $extensionlist[$i]

    # We also need to create the full path to what would be the current file if it existed
    # in the destination directory by reassembling path, name, and extension. This is for
    # convenience and to save space since this var must be used several times.
    $destfullname = "${destinationdir}\${currentname}${extension}"

    # Now we simply copy the files if they do not match a name in the destination
    If(!(Test-Path $destfullname)){
        Write-Host "Moving: ${path}${currentname}${currentextension} | To: " $destinationdir
        Move-Item "${path}\${currentname}${currentextension}" $destinationdir

    # Else, if a file with the current name does exist in the destination, we must rename
    # the current file at the source, then copy it.
    } Else {
        # Establish the $newname var in the 'Else' context   
        $newname = ""

        # While the path $destfullname (established above) is true (i.e. if the file exists
        # in the destination), keep iterating.
        Do{
            # This Do...While first attempts to rename by adding $j (which initially equals 1).
            $newname = "${currentname}(${j})${currentextension}"                            
            # Next, it renames $destfullname so that it may be tested again to see if the new
            # name exists in the destination.
            $destfullname = "${destinationdir}\${newname}"
            # Finally, it adds +1 to $j so that the next iteration will create a sequential,
            # higher number name if the Do...While loop holds true.
            $j++
        } While(Test-Path $destfullname)

        # Once the Do...While loop is invalid, we use the successful new name to rename
        # the current file in the source.
        Rename-Item "${path}${currentname}${currentextension}" $newname

        Write-Host "Moving: " $path $newname "| To: " $destinationdir
        # Then we copy the newly renamed file from source to destination
        Move-Item "${path}\${newname}" $destinationdir
        # Finally, we add +1 to $j to reset it to value '1' for the next file that runs into a
        # conflict.
        $j = 1
    }
    # Add +1 to $i to prepare for next item in $pathlist
    $i++
}
