# This method allows us to remotely start/stop a service:

Get-Service -Name "some service" -ComputerName "targetComputer" | Start-Service

# To get the status of the service to make sure it started, then we can just run:

Get-Service -Name "some service" -ComputerName "targetComputer"
