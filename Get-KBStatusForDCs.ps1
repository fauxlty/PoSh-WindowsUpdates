$DomainName = ""
$Server = ""
$ServerList = ""
$kb = ""
$hotfixID="KB5015019"
$array = 0
$customobject = ""
$ServersToScan = 0
$scandate = get-date -UFormat “%Y-%m-%d %H:%M:%S”
$date = get-date -UFormat “%Y-%m-%d"
$isstaged = ""
$ispatched = ""
$i = 0
$v = 0

#Check user domain for defaults
#$targetdomain=$env:UserDNSDomain

#Manual Domain Name
$DomainName = "homeoffice.wal-mart.com"

$array = @()

#Forest
#$ServerList = ((Get-ADForest -Server $DomainName).Domains | ForEach-Object{ Get-ADDomainController -Filter * -Server $_ }).hostname

#Domain
$ServerList = (Get-ADDomainController -Filter * -Server $DomainName).hostname

#Server List File Import
#$ServerList = Get-Content -Path D:\SEID\Admins\JLC\Coding\PowerShell\patching-list-domaincontrollers.csv
#$ServerList = Get-Content -Path D:\SEID\Admins\JLC\Coding\PowerShell\Reboot-Cycle.txt

#Manual List
#$ServerList = @("S08939NT0057US.HOMEOFFICE.WAL-MART.COM")
#$ServerList = @("PHONT00001USP01.HOMEOFFICE.WAL-MART.COM","S07497NT0015US.HOMEOFFICE.WAL-MART.COM","S08939NT0057US.HOMEOFFICE.WAL-MART.COM","S07497NT0017US.HOMEOFFICE.WAL-MART.COM","S07497NT0020US.HOMEOFFICE.WAL-MART.COM","S07497NT0032US.HOMEOFFICE.WAL-MART.COM","S07497NT0035US.HOMEOFFICE.WAL-MART.COM","S07497NT0037US.HOMEOFFICE.WAL-MART.COM","S07497NT0052US.HOMEOFFICE.WAL-MART.COM")

# Check Installed KB's vs KB Search List
$ServersToScan = $ServerList.count
Write-Host "Checking $ServersToScan Servers"

    foreach ($Server in $ServerList)
    { 
            $isstaged = ""
            $ispatched = ""
            $v++

            #Current percentage of $ServersToScan
            Write-Progress -Activity "Scanning $ServersToScan servers in this list" -PercentComplete (($i/$ServersToScan)*100) -CurrentOperation ($server.ToUpper()) -ID 1

            $kb=get-hotfix -ComputerName $Server | Where-Object {$_.HotfixID -Like $hotfixID} 
                
                    if (($kb.HotFixID).count -gt "0") 
                        {
                           $isstaged = "Yes"
                        } 
                    else 
                        {
                            $isstaged = "No"
                        }
                    if (($kb.InstalledBy).count -gt "0")
                        {
                            $ispatched = "Yes"
                        }
                    else
                        {   
                            $ispatched = "No"
                        }

                

            $os = get-ciminstance -ClassName win32_OperatingSystem -ComputerName $Server
            $customobject = new-object -TypeName PsCustomObject
            $customobject | Add-Member -MemberType NoteProperty -Name 'DC Name' -Value $Server.ToUpper()
            $customobject | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $domainname.ToUpper()
            $customobject | Add-Member -MemberType NoteProperty -Name 'Site' -Value (Get-ADDomainController -Server $dc).site
            $customobject | Add-Member -MemberType NoteProperty -Name 'OS Version' -Value $os.Version
            $customobject | Add-Member -MemberType NoteProperty -Name 'OS Name' -Value $os.Caption
            $customobject | Add-Member -MemberType NoteProperty -Name 'KB' -Value $hotfixID
            $customobject | Add-Member -MemberType NoteProperty -Name 'Staged' -Value $isstaged
            $customobject | Add-Member -MemberType NoteProperty -Name 'Patched' -Value $ispatched
            $customobject | Add-Member -MemberType NoteProperty -Name 'ScanDate' -Value $scandate

            $array = $array + $customobject
            
       }
    

$array.GetEnumerator() | ft -AutoSize
$array | Export-Csv -NoTypeInformation -Force "wmforestpatch-$hotfixID-$date.csv"