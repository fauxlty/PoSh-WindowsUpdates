$tc = 0
(Get-ADForest).Domains | ForEach-Object {
 $tc += (Get-ADDomain -Identity $_ | Select-Object -ExpandProperty ReplicaDirectoryServers).Count
}
$tc