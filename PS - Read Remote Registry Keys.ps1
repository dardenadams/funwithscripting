# Method for reading remote reg keys and subkey values
# Locates the last user to log into the target PC

Clear-Host

# Target machine
$Target = "somemachine"

# Save end result of reg query using OpenRemoteBaseKey on the target
$ReadReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Target)

# Save path within base key to target key
$KeyPath = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'

# Save path of subkey
$Subkey = $ReadReg.OpenSubKey($KeyPath)

# Get value from subkey
$LastUser = $Subkey.GetValue('LastLoggedOnUser')

Write-Host $LastUser
