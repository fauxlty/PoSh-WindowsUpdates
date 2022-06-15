#Based on "CopyFiles.ps1" by Melissa Cronquist, this will zip and ship a folder and path containing the various scripts and tools necessary to promote
#a domain controller in our environment.

#Declare and clear variables
$server = ""
$servers = ""
$ServersToScan = ""
$direxists = ""
$present = 0
$notpresent = 0

#Import list of would-be domain controllers
$servers = Get-Content "D:\SEID\Admins\JLC\Coding\PowerShell\serverlist.txt"
$ServersToScan = $servers.Count

foreach ($server in $servers) {
    Write-Host "Attempting $Server"

    $direxists = Test-Path -Path \\$server\H$\DCPROMO -IsValid

    if ($direxists = "True")
    {
        Copy-Item -Path D:\SEID\Admins\JLC\Coding\DCPROMO\dcpromo.zip -Recurse -destination \\$server\H$\DCPROMO -Force
        Expand-Archive -Path \\$server\H$\DCPROMO\dcpromo.zip -DestinationPath \\$server\H$\DCPROMO -Force
        $present++
    } 
    else {
        New-Item -ItemType "directory" -Path \\$server\H$\DCPROMO -Force
        Copy-Item -Path D:\SEID\Admins\JLC\Coding\DCPROMO\dcpromo.zip -Recurse -destination \\$server\H$\DCPROMO -Force
        Expand-Archive -Path \\$server\H$\DCPROMO\dcpromo.zip -DestinationPath \\$server\H$\DCPROMO -Force
        $notpresent++
    }

}     

Write-Host "Servers with directory: $present"
Write-Host "Servers without directory: $notpresent"
Write-Host "Total servers scanned and copied to: $ServersToScan"