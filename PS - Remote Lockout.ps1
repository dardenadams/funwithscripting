# Script for locking out a user and remotely shutting down any domain PC
# In case you really need to kick someone out of the network quick

Clear-Host
Write-Host "QUICK, CUT THE HARDLINES!"

$reboot? = Read-Host "Do you wish to force a reboot or shutdown? ('no', 'reboot', 'shutdown')"
$creds = "my-domain.local\MyFavAdminUser"

If($reboot? -eq "shutdown"){
    
    $computer = Read-Host "Enter target computer"
    Stop-Computer $computer -Force -Credential $creds
    Write-Host "Shutdown initiated on ${computer}"

    $target = Read-Host "Enter target user"
    Set-ADAccountPassword -Identity "$target" -Reset -Credential $creds
    Write-Host ""
    Write-Host "Password reset for ${target}"

} ElseIf($reboot? -eq "reboot"){
    
    $computer = Read-Host "Enter target computer"
    Restart-Computer $computer -Force -Credential $creds
    Write-Host "Restart initiated on ${computer}"

    $target = Read-Host "Enter target user"
    Set-ADAccountPassword -Identity "$target" -Reset -Credential $creds
    Write-Host ""
    Write-Host "Password reset for ${target}"

} ElseIf($reboot? -eq "nvm"){

    Write-Host "Operation Cancelled"    
    Exit

} Else {
    
    $target = Read-Host "Enter target user"
    Set-ADAccountPassword -Identity "$target" -Reset -Credential $creds
    Write-Host ""
    Write-Host "Password reset for ${target}"
}
