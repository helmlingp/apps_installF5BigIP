<#	
  .Synopsis
    This powershell script installs the F5 BigIP Edge Client & configures for Always Connected Mode using certificate
  .NOTES
	  Created:   	    January, 2021
	  Created by:	    Phil Helmling, @philhelmling
	  Organization:   VMware, Inc.
	  Filename:       installF5BigIP.ps1
	.DESCRIPTION
	  Installs the F5 BigIP Edge Client & configures for Always Connected Mode using certificate
  .EXAMPLE
    powershell.exe -ep bypass -file .\installF5BigIP.ps1
#>

$current_path = $PSScriptRoot;
if ($PSScriptRoot -eq "") {
    $current_path = "C:\Airwatch";
}

#Install F5 BigIP Edge Client
$BigIPClient = "$current_path\BIGIPEdgeClient.exe"
Start-Process $BigIPClient -wait

#Configure F5 BigIP Edge Client to enable Always On Machine Tunnel
#https://techdocs.f5.com/en-us/edge-client-7-1-8/big-ip-access-policy-manager-edge-client-and-application-configuration-7-1-8/big-ip-edge-client-for-windows.html
$VPNServers = "SERVER"
$Key = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\F5MachineTunnelService\Parameters\VPNServers"
$certificate = "certificate.cer"
if (Get-Item -Path $Key -ErrorAction Ignore) {
    Set-ItemProperty -Path "Registry::$Key" -Name "Enabled" -Type String -Value $VPNServers -Force
} else {
    New-Item -Path "Registry::" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "Registry::$Key" -Name "Server0" -Type String -Value $VPNServers -Force
}
# Import into LocalMachine store to be used by service account windows service - https://docs.microsoft.com/en-us/dotnet/framework/wcf/feature-details/working-with-certificates
Import-Certificate -FilePath "$current_path\$certificate" -CertStoreLocation Cert:\LocalMachine\My
