#Domain
$ServerList = Get-Content -Path D:\SEID\Admins\JLC\Coding\PowerShell\patching-list-domaincontrollers.csv

# Check Installed KB's vs KB Search List
Write-Host "Checking $($ServerList.count) Servers"

#$array=@()

foreach ($Server in $ServerList | Select-Object) {
    $ServerHotfix = get-hotfix -ComputerName $server | Where-Object { $_.HotfixID -Like "*KB5015019*" }
    $installedon = $ServerHotfix.InstalledOn
    If (

        $null -eq $installedon

    )

    { $installedon = "Hotfix Not Installed On $server" }

    #{Restart-Computer -ComputerName $server -force
    #Start-Sleep -Seconds 180}

    $result = "$server,$installedon"
    $result
}
