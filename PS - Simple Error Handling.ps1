# Error handling example

Try{
    # Some risky code here
    Copy-Item "C:\temp\somefile.txt" "C:\newlocation"
} Catch {
    # Errorname will return only the name of the exception
    $errorname = $_.Exception.GetType().FullName

    # Errordetails returns the exception message
    $errordetails = $_.Exception.Message

    # We can set Foreground color to red for red error text
    Write-Host "Error during attempt to copy file" -ForegroundColor Red
    Write-Host "Error Type: ${errorname}" -ForegroundColor Red
    Write-Host "Details: ${errordetails}" -ForegroundColor Red
}
