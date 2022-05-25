#testing

$array=@()
#$server=""
$kb=""
$totaldcs=""
$customobject=""
$os=""
$ispatched=""
$i=0
$v=0
$DomainName = "Wal-Mart.com"


#Check user domain for defaults
$targetdomain=$env:UserDNSDomain

$kb = Read-Host "Please enter the KB article in question"

$totaldomains = ((Get-ADDomainController -Server $domainname -Filter *).HostName).count
Write-Host "Total domains found in"$targetdomain.ToUpper()": $totaldomains"

foreach ($domainname in (Get-ADForest -Server $targetdomain).Domains)

{
        $totaldomaindcs = ((Get-ADDomainController -Server $domainname -Filter *).HostName).count
        Write-Host "Total DCs found in"$domainname.ToUpper()": $totaldomaindcs"

        #Clear current DC counter
        $v=0

        #Start counting domain names processed
        $i++

        Write-Progress -Activity "Scanning Domain" -PercentComplete (($i/$totaldomains)*100) -CurrentOperation ($domainname.ToUpper()) -ID 1

        foreach ($dc in (Get-ADDomainController -Server $domainname -Filter *).HostName)
        
            {
            $Hotfix = Get-HotFix -ComputerName $dc
                if ($hotfix -like "*$kb*") 
                    {
                        $ispatched = "Yes"
                    } 
            
                else 
                    {
                        $ispatched = "No"
                    }

            $os = get-ciminstance -ClassName win32_OperatingSystem -ComputerName $dc
            $customobject = new-object -TypeName PsCustomObject
            $customobject | Add-Member -MemberType NoteProperty -Name 'DC Name' -Value $dc.ToUpper()
            $customobject | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $domainname.ToUpper()
            $customobject | Add-Member -MemberType NoteProperty -Name 'Site' -Value (Get-ADDomainController -Server $dc).site
            $customobject | Add-Member -MemberType NoteProperty -Name 'OS Version' -Value $os.Version
            $customobject | Add-Member -MemberType NoteProperty -Name 'OS Name' -Value $os.Caption
            $customobject | Add-Member -MemberType NoteProperty -Name 'KB' -Value $kb
            $customobject | Add-Member -MemberType NoteProperty -Name 'Patched' -Value $ispatched

            $array = $array + $customobject

            $v++

            #Current DC processing percentage
            Write-Progress -Activity "Current DC" -PercentComplete (($v/$totaldomaindcs)*100) -CurrentOperation $dc.ToUpper() -parentID 1
            
            }

}
    
$totaldomains=(Get-ADForest -Server $targetdomain).Domains.count
write-host "Total domains found = $totaldomains"

$totaldcs = $array.Count
write-host "Total Domain Controllers found = $totaldcs"

Write-host "Domain Controllers with $kb = $dcs"
$array | Format-Table -autosize
$array | Export-Csv wmforestpatch-KB5013952-CAPS.csv

$array=$null