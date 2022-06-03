$Server = ""
$ServerList = ""
$ServerUptime = ""

#Manual list
#$ServerList = Get-Content -Path D:\SEID\Admins\JLC\Coding\PowerShell\patching-list-domaincontrollers.csv
#$ServerList = @("S08939NT0004US.homeoffice.Wal-Mart.com","S08939NT0005US.homeoffice.Wal-Mart.com","S08939NT0008US.homeoffice.Wal-Mart.com")

#Get list from file
$ServerList = Get-Content -Path D:\SEID\Admins\JLC\Coding\PowerShell\Reboot-Cycle.txt

Write-Host "Checking $($ServerList.count) Servers"
foreach ($Server in $ServerList) {
    $ServerUptime = Get-uptime $server
    Write-host $ServerUptime
}