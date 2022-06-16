$server = ""
$servers = ""
$ServersToScan = 0
$null = [bool]$isDC #Looks for SYSVOL share to see if it's still a current DC
$null = [bool]$InGroup
$insecgroup = 0
$notinsecgroup = 0
$isaDC = 0 #DC counter
$isaStagedDC = 0
$notaStagedDC = 0
$notaDC = 0
$mixedStatus = 0
$SecurityGroup = "ADDS-GPOACL-DomainControllerIsolation"

$servers = Get-Content ".\serverlist.txt"
#$servers = Get-Content "D:\SEID\Admins\JLC\Coding\PowerShell\serverlist.txt"
$ServersToScan = $servers.Count

foreach ($server in $servers) {
    Write-Host "Checking $Server DC staging status" 
    $hostaccount = ($server.split('.')[0])
    $hostdomain = $server.Substring($server.IndexOf(".") + 1)
    #$SAMAccountName = ($server.split('.')[0] + '$') 
    $isDC = ((net view \\$server) -match "sysvol").count

    if ($isDC -eq 1) {
        $hostsite = (Get-ADDomainController -Server $server).site
    }
    else {
        $isDC = 0
    }
    
    #$server; $hostdomain; $hostaccount,$SAMAccountName 
    $InGroup = ((Get-ADGroupMember -Identity $SecurityGroup -Server "$hostdomain").name | Where-Object { $_ -like "$hostaccount*" }).count

    if (($ingroup -eq $true) -and ($isDC -eq 1)) {
        #Check to see if $server is in $securitygroup
        #Write-host "$server is in $securitygroup for $hostdomain" -ForegroundColor Green

        #Find site location, if present
        if ($hostsite -like "*Isolation*") {
            Write-host "$server is fully staged in Isolation" -ForegroundColor Green
            $insecgroup++
            $isaStagedDC++
            #$isaDC++
        }
        elseif ($hostsite -like "*DecomHolding*") {
            Write-host "$server is in DecomHolding" -ForegroundColor Magenta
            $insecgroup++
            $isaDC++
        }
        else {
            Write-host "$server is in $hostsite but still in $securitygroup; CHECK STATUS" -ForegroundColor Yellow
            $notinsecgroup++
            $notaStagedDC++
            $mixedStatus++
            #$isaDC++
        }
        
    }
    elseif (($ingroup -eq $true) -and ($isDC -ne 1)) {
        #Write-host "$server is in $securitygroup for $hostdomain" -ForegroundColor Green
        Write-host "$server is in $securitygroup but not a DC" -ForegroundColor Red
        $insecgroup++
        $notaStagedDC++
        $notaDC++
        $mixedStatus++
    }
    elseif (($ingroup -ne $true) -and ($isDC -eq 1)) {
        #Write-host "$server is NOT present in $securitygroup" -ForegroundColor Blue
        Write-host "$server is in $hostsite and a deployed DC" -ForegroundColor Cyan
        $notinsecgroup++
        $isaDC++
    }
         
    else {
        write-host "$server is NOT present in $securitygroup and has no site defined" -ForegroundColor Red
        #If the server isn't in the appropriate security group, add it to said group; be sure to uncomment the $SAMAccountName variable up above
        #Add-ADGroupMember -Identity 'ADDS-GPOACL-DomainControllerIsolation' -Members $SAMAccountName -Server $hostdomain
        $notinsecgroup++
        $notaStagedDC++
        $mixedStatus++
    }
}  

Write-Host "***************************************************************************"
Write-Host "Servers that are STAGED DCs: $isaStagedDC" -ForegroundColor Green
Write-Host "Servers that are DEPLOYED DCs: $isaDC" -ForegroundColor Cyan
Write-Host "Servers in MIXED STATE (CHECK STATUS): $mixedStatus" -ForegroundColor Yellow
#Write-Host "Servers in Isolation Group: $insecgroup" -ForegroundColor DarkYellow
#Write-Host "Servers NOT in Isolation Group currently: $notinsecgroup" -ForegroundColor Yellow
Write-Host "Servers that are NOT DCs: $notaDC" -ForegroundColor Red
Write-Host "Total servers scanned for DC role: $ServersToScan"
Write-Host "***************************************************************************"

#Close up shop
#$array=@()
[gc]::Collect()