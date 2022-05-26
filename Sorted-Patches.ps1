#Check user domain for defaults
#$targetdomain=$env:UserDNSDomain
$DomainName = $env:USERDNSDOMAIN

#Forest
$ServerList = ((Get-ADForest -Server $DomainName).Domains | ForEach-Object{ Get-ADDomainController -Filter * -Server $_ }).hostname

#Domain
#$ServerList = (Get-ADDomainController -Filter * -Server $DomainName).hostname

#Manual List
#$ServerList = @("S07497NT0138US.HOMEOFFICE.WAL-MART.COM")
#$ServerList = @("PHONT00001USP01.HOMEOFFICE.WAL-MART.COM","S07497NT0015US.HOMEOFFICE.WAL-MART.COM","S07497NT0017US.HOMEOFFICE.WAL-MART.COM","S07497NT0020US.HOMEOFFICE.WAL-MART.COM","S07497NT0032US.HOMEOFFICE.WAL-MART.COM","S07497NT0035US.HOMEOFFICE.WAL-MART.COM","S07497NT0037US.HOMEOFFICE.WAL-MART.COM","S07497NT0052US.HOMEOFFICE.WAL-MART.COM")

# Check Installed KB's vs KB Search List
Write-Host "Checking $($ServerList.count) Servers"

$sorted={
foreach ($Server in $ServerList) {
 get-hotfix -ComputerName $Server | Where-Object {$_.HotfixID -Like "KB5015019"} | Format-Table -AutoSize
 #get-hotfix -ComputerName $Server | where {$_.installedon -Like "*2022"} | Sort-Object -Property InstalledOn | ft -AutoSize
 #get-hotfix -ComputerName $Server | Sort-Object -Property InstalledOn -Descending | ft -AutoSize
}
}

Write-host $sorted | Sort-Object -Property InstalledOn | Format-Table -AutoSize