# For making it a little easier to enter pssessions
# Store in root PS dir and name 'session.ps1' for easy access

Clear-Host

Write-Host "Welcome to PSSession Starter!"

$target = Read-Host "Please enter target computer"

If($target -eq "nvm"){
    Write-Host "Operation Cancelled"
    Exit
} Else {

Write-Host "Starting session, please wait ..."

Enter-PSSession -ComputerName $target

Clear-Host
}
