# Finds last write time of a file. Useful for sorting large numbers of files based
# on date of last usage.

Clear-Host

$target = "C:\somefile.txt"
$date = [datetime](Get-ItemProperty -Path $target -Name LastWriteTime).LastWriteTime

Write-Host $date
