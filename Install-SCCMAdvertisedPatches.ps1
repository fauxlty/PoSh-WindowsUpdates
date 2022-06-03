$Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName XXX.br.wal-mart.com | Where-Object { $_.EvaluationState -like "*0*" -or $_.EvaluationState -like "*1*" })

Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (, $Application) -Namespace root\ccm\clientsdk -ComputerName XXX.br.wal-mart.com