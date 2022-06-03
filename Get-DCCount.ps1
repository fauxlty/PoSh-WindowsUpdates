$domain = ""
$arrayTotalDCCount = @()

$forest = Get-ADForest
$domainlist = get-adforest | Select-Object -expandproperty domains
Write-Host "Current forest is $forest"
# ForEach ($domain in $domainlist)
# {
#     Write-Host $domain
# }
    
foreach ($domain in $domainlist) {
    $DClist = Get-ADDomainController -Server $domain -Filter *
    $GClist = Get-Addomaincontroller -Server $domain -filter *  |  where-object { $_.isglobalcatalog -eq $true }
   
    $GCnumber = $GClist.count
    $DCnumber = $DClist.count
    
    write-host "The number of Domain Controllers in $domain domain is $DCnumber"
    write-host "The number of Global Catalog hosts in $domain domain is $GCnumber"

    $arrayTotalDCCount = $arrayTotalDCCount + $DCnumber

    write-host $domain
   
}
write-host "The total number of Domain Controllers is $arrayTotalDCCount"