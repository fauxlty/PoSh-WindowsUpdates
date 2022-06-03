function triggerAvailableSupInstall {
  Param
  (
    [String][Parameter(Mandatory = $True, Position = 1)] $Computername,
    [String][Parameter(Mandatory = $True, Position = 2)] $SupName
 
  )
  Begin {
    $AppEvalState0 = "0"
    $AppEvalState1 = "1"
    #$ApplicationClass = [WmiClass]"root\ccm\clientSDK:CCM_SoftwareUpdatesManager"
  }
 
  Process {
    If ($SupName -Like "All" -or $SupName -like "all") {
      Foreach ($Computer in $Computername) {
        $Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer | Where-Object { $_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*" })
        Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (, $Application) -Namespace root\ccm\clientsdk -ComputerName $Computer
 
      }
 
    }
    Else
    {
      Foreach ($Computer in $Computername) {
        $Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer | Where-Object { $_.EvaluationState -like "*$($AppEvalState)*" -and $_.Name -like "*$($SupName)*" })
        Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (, $Application) -Namespace root\ccm\clientsdk -ComputerName $Computer
 
      }
 
    }
  }
  End {}
}

$DomainName = "lab.wal-mart.com"
#Forest
$AllDCinForest = ((Get-ADForest -Server $DomainName).Domains | ForEach-Object { Get-ADDomainController -Filter * -Server $_ }).hostname
#Domain
#$AllDCinForest = (Get-ADDomainController -Filter * -Server $DomainName).hostname
foreach ($DC in $AllDCinForest) {
  Trigger-AvailableSupInstall -Computername $DC -Supname All
  Write-Host "Triggering Patches -- $($DC)"
}