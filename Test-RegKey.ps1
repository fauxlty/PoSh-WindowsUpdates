$Computers = @("RemotePCName1", "RemotePCName2")
$Hive = [Microsoft.Win32.RegistryHive]::LocalMachine
$KeyPath = 'Path\to\reg\key'
$Value = 'ValueInKey'

Foreach ($Computer in $Computers) {
    Get-Service -Name RemoteRegistry -ComputerName $Computer | Set-Service -Status Running
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $Computer)
    $key = $reg.OpenSubKey($KeyPath)

    If ($key.GetValue($Value)) {
        $Result = $key.GetValue($Value)
        $Txt = "$ComputerName - $Result"
        $Txt >> C:\textdoc.txt
    }
    Get-Service -Name RemoteRegistry -ComputerName $Computer | Set-Service -Status Stopped
}