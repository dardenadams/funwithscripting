# Script to make unlocking AD Account quickly
Clear-Host

$tuser = Read-Host "Enter locked username"

If($tuser -eq "nvm"){
    Write-Host "Operation Cancelled"
    Exit
} Else {

Unlock-ADAccount -Identity $tuser -Credential "my-domain\MyFavAdmin"

Write-Host "${tuser} has been unlocked"
}
