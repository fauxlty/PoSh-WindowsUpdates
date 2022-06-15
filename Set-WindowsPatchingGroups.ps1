$hostname = (hostname | get-adcomputer).dnshostname
$hostdomain = (Get-WmiObject win32_computersystem).Domain
$hostaccount = ($hostname.split('.')[0] + '$')
#$fqdn = [System.Net.Dns]::GetHostByName($env:computerName) 
Add-ADGroupMember -Identity 'ADDS-SCCM-Patching' -Members "$servername$" -Server $serverdomain

$hostname = (hostname | get-adcomputer).dnshostname; $hostdomain = (Get-WmiObject win32_computersystem).Domain; $hostaccount = ($hostname.split('.')[0] + '$'); $hostname; $hostdomain; $hostaccount

Add-ADGroupMember -Identity 'ADDS-SCCM-Patching' -Members $hostaccount -Server $hostdomain