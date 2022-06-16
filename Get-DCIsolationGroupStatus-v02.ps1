$server = ""
$servers = ""
$ServersToScan = 0
$null = [bool]$isdc
$null = [bool]$InGroup
$insecgroup = 0
$notinsecgroup = 0
$isaDC = 0
$notaDC = 0
$SecurityGroup = "ADDS-GPOACL-DomainControllerIsolation"

$servers = Get-Content "serverlist.txt"
#$servers = Get-Content "D:\SEID\Admins\JLC\Coding\PowerShell\serverlist.txt"
$ServersToScan = $servers.Count
#$array=1..($servers.count)

foreach ($server in $servers) {
    Write-Host "Checking if $Server is in $SecurityGroup" -ForegroundColor Cyan
    $hostaccount = ($server.split('.')[0])
    $hostdomain = $server.Substring($server.IndexOf(".") + 1)
    $SAMAccountName = ($server.split('.')[0] + '$') 
    $isdc = ((net view \\$server) -match "sysvol").count

    if ($isdc -eq 1) {
        $hostsite = (Get-ADDomainController -Server $server).site
    }
    else {
        $isdc = 0
    }
        
    #$server; $hostdomain; $hostaccount,$SAMAccountName 
    $InGroup = ((Get-ADGroupMember -Identity $SecurityGroup -Server "$hostdomain").name | Where-Object { $_ -like "$hostaccount*" }).count

    if (($ingroup -eq $true) -and ($isdc -eq 1)) {
        #Only servers that are promoted to Domain Controller will make it to this loop
        #Find out if this DC is in the DC Isolation security group and which site it's currently in

        #Check to see if $server is in $securitygroup
        Write-host "$server is in $securitygroup for $hostdomain" -ForegroundColor Green

        #Find site location, if present
        if ($hostsite -like "*Isolation*") {
            Write-host "$server is in isolation and staged" -ForegroundColor Green
            $insecgroup++
            $isaDC++
        }
        elseif ($hostsite -like "*DecomHolding*") {
            Write-host "$server is in DecomHolding" -ForegroundColor Magenta
            $insecgroup++
            $isaDC++
        }
        else {
            Write-host "$server is in $hostsite" -ForegroundColor Yellow
            $notinsecgroup++
            $isaDC++
        }       
    }
    elseif (($ingroup -eq $true) -and ($isdc -ne 1)) {
        Write-host "$server is in $securitygroup for $hostdomain" -ForegroundColor Green
        Write-host "$server is not a DC" -ForegroundColor Black -BackgroundColor DarkYellow
        $insecgroup++
        $notaDC++
    }
    elseif (($ingroup -ne $true) -and ($isdc -eq 1)) {
        Write-host "$server is NOT present in $securitygroup" -ForegroundColor Red -BackgroundColor White
        Write-host "$server is in $hostsite" -ForegroundColor DarkYellow
        $notinsecgroup++
        $notaDC++
    }    
    else {
        write-host "$server is NOT present in $securitygroup and has no site defined" -ForegroundColor Red -BackgroundColor Yellow
        #Add-ADGroupMember -Identity 'ADDS-GPOACL-DomainControllerIsolation' -Members $SAMAccountName -Server $hostdomain
        $notinsecgroup++
        $notaDC++
    }
}  

Write-Host "Servers that are staged: $isaDC" -ForegroundColor Cyan
Write-Host "Servers that are NOT Domain Controllers: $notaDC" -ForegroundColor Red
Write-Host "Servers in Isolation Group: $insecgroup" -ForegroundColor Green
Write-Host "Servers NOT in Isolation Group currently: $notinsecgroup" -ForegroundColor Yellow
Write-Host "Total servers scanned for DC role: $ServersToScan" -ForegroundColor Green