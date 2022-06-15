<#
.SYNOPSIS
#==========================================================================
 DCSSLInfo.PS1
 Created by: james.carter@wal-mart.com
 DATE  : 2022-06-15

 COMMENT: This Script will take a target directory, compress it using Windows' default compression via PS, and copy the newly-created ZIP file to remote servers using a user-defined target share and path.

==========================================================================

.Notes
 VERSION HISTORY:
   1.0 2022-06-15 - Initial release

.Description
 Create ZIP file using local target directory path, distribute to servers in "serverlist.txt", and decompress the file into the destination path.

.EXAMPLE
===============================================================================
Select a local directory path to compress and distribute, and decompress the ZIP on each target server named in "serverlist.txt".

    -Create your "serverlist.txt" and list the FQDN of the servers you need to distribute to.
    -Define the source path, such as "D:\SEID\Scripts\DCPROMO\DomainControllerFiles" that needs to be compressed and distributed.
    -Run script without arguments/options in the command line, as all variables are defined internally.

===============================================================================
#>


$ZIPSourceDir = "D:\SEID\Scripts\DCPROMO\DomainControllerFiles"
$ZIPFilePath = "D:\SEID\Admins\JLC\Coding\DCPROMO\dcpromo.zip"
$DestSharePath = "H$\DCPROMO"
$ZIPDestTargetPath = "\DomainControllerFiles"
$ZIPDestDirectoryPath = $ZIPDestTargetPath
$server = ""
$servers = ""
$ServersToScan = ""
[bool]$direxists = 0
$present = 0
$notpresent = 0

#Create ZIP archive of current files in the "DCPROMO\DomainControllerFiles" 
#ZIPLocalSourceDir="D:\SEID\Scripts\DCPROMO\DomainControllerFiles"
#$ZIPSourceFilePath="D:\SEID\Admins\JLC\Coding\DCPROMO\dcpromo.zip"
#$DestSharePath="($.split('.')[0]+'$')"
#$ZIPDestTargetPath="$Server\$DestSharePath"

Compress-Archive -DestinationPath $ZIPFilePath -Force $ZIPSourceDir -CompressionLevel Fastest

$servers = Get-Content "D:\SEID\Admins\JLC\Coding\PowerShell\serverlist.txt"
$ServersToScan = $servers.Count

foreach ($server in $servers) {
	Write-Host "Attempting $Server" -ForegroundColor Cyan 

	$ZIPDestTargetPath = "\\$Server\$DestSharePath"
	$direxists = (Test-Path -Path $ZIPDestDirectoryPath -IsValid)
	write-host "Copying $ZIPFilePath to $ZIPDestTargetPath"

	if ($direxists = $true) {
		Copy-Item -Path $ZIPFilePath -Recurse -destination $ZIPDestTargetPath -Force
		Expand-Archive -Path "$ZIPDestTargetPath\dcpromo.zip" -DestinationPath $ZIPDestTargetPath -Force
		$present++
	} 
	else {
		New-Item -ItemType "directory" -Path $ZIPDestTargetPath -Force
		Copy-Item -Path $ZIPFilePath -Recurse -destination $ZIPDestTargetPath -Force
		Expand-Archive -Path "$ZIPDestTargetPath\dcpromo.zip" -DestinationPath $ZIPDestTargetPath -Force
		$notpresent++
	}

}     

Write-Host "Servers with directory: $present" -ForegroundColor Cyan
Write-Host "Servers without directory initially: $notpresent" -ForegroundColor Yellow
Write-Host "Total servers scanned and copied to: $ServersToScan" -ForegroundColor Green

#Close up shop
#$array=@()
[gc]::Collect()