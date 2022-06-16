$Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', 'S07497NT0145US.CAM.WAL-MART.COM')
$RegistryKey = $Registry.OpenSubKey("SYSTEM\CurrentControlSet\Services\Netlogon\Parameters", $true)
$RegistryKey.GetValue('DynamicSiteName')
$RegistryKey