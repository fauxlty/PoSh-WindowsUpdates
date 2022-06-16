$servers = Get-Content "serverlist.txt"

foreach ($server in $servers) {
    $isdc = ((net view \\$server) -match "sysvol").count
    $isdc

    if ($isdc -eq 1) {
        $server
    }
    else {
        Write-Host "$server is not a DC"
    }
}


#if (($ingroup -eq $true) -and ($isdc -eq 1))