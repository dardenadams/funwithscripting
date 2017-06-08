# Script for remotely shutting down a domain PC
# In case you really need to kick someone out of the network quick

$creds = "my-domain.local\SomeAdminUser"
$computer = Read-Host "Enter target computer"

If($computer -eq "nvm"){
    Exit
} Else {
    Stop-Computer $computer -Force -Credential $creds
    Write-Host "Shutdown initiated on ${computer}"
}
