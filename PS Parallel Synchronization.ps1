# ------------------------------- Parallel Synchronization Method --------------------------------
# This script explains a common problem when iterating through a number of objects. Say that you require
# two pieces of information from each object in a list of objects and you want both pieces saved to two
# separate arrays. In this case, we want the FullName and the Name for a large list of files, then we
# want to iterate through the list of FullNames and utilize the Name that matches that FullName, all
# within a Foreach loop. There are two methods:
# - One is to use TrimStart to remove everything except the Name from the FullName string, which would
#   eliminate the need for a Name list altogether, but which has to deal with the limitations of Regular
#   Expressions -namely that ANY occurance of ANY character that you specify with TrimStart will be
#   removed. This means that if you have a FullName like this: 'C:\temp\directory\examplefile.txt', the
#   only way to get just 'examplefile.txt' would be to Trimstart("C:\temp\directory"). Since there's an
#   'e' in the regular expression, the first letter of 'examplefile.txt' would also be removed, which
#   would make the results less than ideal.
# - The second solution is to use Parallel Synchronization, described below:

Clear-Host
# Variables for:
# Folder where all objects (files) are stored
$documents = "C:\temp\somedocs"

# Arrays for the list of FullNames and Names
$filelist = @()
$namelist = @()

# Incremental integer variable, starting at zero (first item in an array is always at position 0)
$i = 0

# Get-ChildItem returns a list of all documents in the chosen directory
Get-ChildItem $documents -Recurse | Where-Object {$_.Attributes -ne 'Directory'} | Foreach-Object{
    
    # Add document FullNames and Names to arrays
    $filelist += $_.Fullname
    $namelist += $_.Name

}

# Foreach FullName, we want to get the short Name from it's array and write it to host
Foreach($file in $filelist){

    # The short Name of the first item in the Foreach loop will correspond to the
    # first item in the short $namelist array. $i represents the current position
    # we should be in the $namelist array.
    $name = $namelist[$i]

    Write-Host "The short name of file #${i} is: ${name}"

    # Add plus 1 to $i to prepare for next iteration
    $i++
}

