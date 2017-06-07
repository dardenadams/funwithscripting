# Tests domain PCs for presence of a specific file
# To complicate, must locate a file in the last logged on user's Documents folder

Clear-Host

# Get list of PCs from txt file
$MachineList = "C:\PCList.txt"

# Iterate through machine list
Get-Content $machinelist | Foreach {
    
    # Ping remote machine to make sure it's online first
    If(Test-Connection -ComputerName $_ -Delay 1 -Count 1 -Quiet){
        # Find last logged on user
        $ReadReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$_)
        $KeyPath = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'
        $Subkey = $ReadReg.OpenSubKey($KeyPath)
        $RawUser = $Subkey.GetValue('LastLoggedOnUser')

        # Remove domain name (for domain users) to get plain username
        $LastUser = $RawUser.Replace("MY_DOMAIN\", "").Replace("MY-DOMAIN.LOCAL\", "").Replace("my-domain.local\", "").Replace("my_domain\", "")

        # Test path located in last logged on user's Documents folder. In this case, an Outlook data file.
        $ArchivePath = "\\${_}\C$\Users\${LastUser}\Documents\Outlook Files\archive.pst"

        # Return results
        If(Test-Path $ArchivePath){
            Write-Host "Archive found on: ${_}, Username: ${LastUser}"
            Add-Content "D:\scratch\test.txt" "Archive found on: ${_}, Username: ${LastUser}"
        } Else {
            Write-Host "No Archive found on: ${_}, ${LastUser}"
        }
    } Else {
        Write-Host "Can't connect to ${_}"
    }
}
