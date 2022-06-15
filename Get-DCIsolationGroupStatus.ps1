$ServersToScan = 0
$null = [bool]$InGroup
$present = 0
$notpresent = 0

$servers = Get-Content "serverlist.txt"
$ServersToScan = $servers.Count

#$SecurityGroup="ADDS-DSCoreSAAdmins"
$SecurityGroup = "ADDS-GPOACL-DomainControllerIsolation"

foreach ($server in $servers) {
    #Write-Host "Checking if $Server is in $SecurityGroup" -ForegroundColor Cyan
    $hostname = $server
    $hostaccount = ($hostname.split('.')[0])
    #$hostname.Substring($hostname.IndexOf(".") + 1)
    $hostdomain = $server.Substring($server.IndexOf(".") + 1) 
    $SAMAccountName = ($hostname.split('.')[0] + '$') 
    #$hostname; $hostdomain; $hostaccount,$SAMAccountName 
    $InGroup = ((Get-ADGroupMember -Identity $SecurityGroup -Server "$hostdomain").name | Where-Object { $_ -like "$hostaccount*" }).count
    #$ingroup

    if ($ingroup -eq $true) {
        #write-host "Account is present in $securitygroup" -ForegroundColor Green
        Write-host "$hostname is in $securitygroup for $hostdomain" -ForegroundColor Green
        $present++
    } 
    else {
        write-host "$hostname is NOT present in $securitygroup" -ForegroundColor Red
        Add-ADGroupMember -Identity 'ADDS-GPOACL-DomainControllerIsolation' -Members $SAMAccountName -Server $hostdomain
        $notpresent++
    }

}     

Write-Host "Servers in Isolation Group: $present" -ForegroundColor Cyan
Write-Host "Servers NOT in Isolation Group Initially: $notpresent" -ForegroundColor Yellow
Write-Host "Total servers scanned for Group Membership: $ServersToScan" -ForegroundColor Green