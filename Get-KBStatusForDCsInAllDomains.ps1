$array=@()
$server=""
$kb=""
$HotFixID=""
$totaldcs=""
$totaldomains=""
$totaldomainservers=""
$customobject=""
$os=""
$isstaged=""
$ispatched=""
$scandate=get-date -UFormat “%Y-%m-%d %H:%M:%S”
$date = get-date -UFormat “%Y-%m-%d"
$i=0
$v=0
$p=0
$s=0
$targetdomain = "Wal-Mart.Com"

#Check user domain for defaults
#$targetdomain=$DomainName
#$targetdomain=$env:UserDNSDomain
$domainname = $targetdomain

$HotFixID = Read-Host "Please enter the KB article in question"

$forestname = (Get-ADForest -Server $DomainName).rootdomain
$totaldomains = ((Get-ADForest -Server $DomainName).Domains).count

Write-Host "Total domains found in"$targetdomain.ToUpper()": $totaldomains"

foreach ($domainname in (Get-ADForest -Server $targetdomain).Domains)

{
        $totaldomainservers = ((Get-ADDomainController -Server $domainname -Filter *).HostName).count
        Write-Host "Total DCs found in"$domainname.ToUpper()": $totaldomainservers"

        #Clear current DC counter
        $v=0

        #Start counting domain names processed
        $i++

        Write-Progress -Activity "Scanning $i of $totaldomains domains in forest $forestname" -PercentComplete (($i/$totaldomains)*100) -CurrentOperation ($domainname.ToUpper()) -ID 1

        foreach ($server in (Get-ADDomainController -Server $domainname -Filter *).HostName)
        
            {
            $isstaged = ""
            $ispatched = ""
            $v++

            #Current percentage of $ServersToScan
            Write-Progress -Activity "Scanning $v of $totaldomainservers servers in this domain" -PercentComplete (($v/$totaldomainservers)*100) -CurrentOperation ($server.ToUpper()) -parentID 1

            $kb=get-hotfix -ComputerName $Server | Where-Object {$_.HotfixID -Like "*$hotfixID*"} 
                
                    if (($kb.HotFixID).count -gt "0") 
                        {
                           $isstaged = "Yes"
                           $s++
                        } 
                    else 
                        {
                            $isstaged = "No"
                        }
                    if (($kb.InstalledOn).count -gt "0")
                        {
                            $ispatched = "Yes"
                            $p++
                        }
                    else
                        {   
                            $ispatched = "No"
                        }

                

            $os = get-ciminstance -ClassName win32_OperatingSystem -ComputerName $Server
            $customobject = new-object -TypeName PsCustomObject
            $customobject | Add-Member -MemberType NoteProperty -Name 'DC Name' -Value $Server.ToUpper()
            $customobject | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $domainname.ToUpper()
            $customobject | Add-Member -MemberType NoteProperty -Name 'Site' -Value (Get-ADDomainController -Server $server).site
            $customobject | Add-Member -MemberType NoteProperty -Name 'OS Version' -Value $os.Version
            $customobject | Add-Member -MemberType NoteProperty -Name 'OS Name' -Value $os.Caption
            $customobject | Add-Member -MemberType NoteProperty -Name 'KB' -Value $hotfixID
            $customobject | Add-Member -MemberType NoteProperty -Name 'Staged' -Value $isstaged
            $customobject | Add-Member -MemberType NoteProperty -Name 'Patched' -Value $ispatched
            $customobject | Add-Member -MemberType NoteProperty -Name 'ScanDate' -Value $scandate
            $customobject | Add-Member -MemberType NoteProperty -Name 'TimeScanned' -Value (get-date -UFormat “%Y-%m-%d %H:%M:%S”)

            $array = $array + $customobject
            
            }

}
    
write-host "Total domains found = $totaldomains"
$totaldcs = $array.Count
write-host "Total Domain Controllers found = $totaldcs"
write-host "DCs with $hotfixID staged: $s"
write-host "DCs with $hotfixID installed: $p"

$array | Format-Table -autosize
$array | Export-Csv -NoTypeInformation -Force "KBScan-$forestname-$hotfixID-$date.csv"

#Close up shop
#$array=@()

#[gc]::Collect()