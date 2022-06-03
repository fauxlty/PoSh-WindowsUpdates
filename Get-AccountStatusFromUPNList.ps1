#Variables
$account = ""
$accountlist = "" 
$array = @()
$i = 0

#Get list of accounts
$accountlist = Get-Content -Path D:\SEID\Admins\JLC\Coding\PowerShell\Account-Status.txt

$totalaccounts = $accountlist.count

Foreach ($account in $accountlist) {

    #Parse samaccountname and domainname suffix from UPN
    #$address = ""
    $Name = $account.Split("@")[0]
    $Name
    $Domain = $account.Split("@")[1]
    $Domain

    #Get account info using samaccountname and domainname
    #Get-ADUser -Identity "$name" -Server $domain | Out-File "D:\SEID\Admins\JLC\Coding\PowerShell\RemovedAccountsLog-$(get-date -UFormat “%Y-%m-%d").txt" -Encoding ASCII -Append

    $status = Get-ADUser -Identity "$name" -Server $domain

    if (($status).count -gt "0") {
        $ispresent = "Yes"
    } 

    else {
        $ispresent = "No"
    }


    $customobject = new-object -TypeName PsCustomObject
    $customobject | Add-Member -MemberType NoteProperty -Name 'UPN' -Value $account.ToUpper()
    $customobject | Add-Member -MemberType NoteProperty -Name 'samaccountname' -Value $domainname.ToUpper()
    $customobject | Add-Member -MemberType NoteProperty -Name 'AccountDomain' -Value $domainname.ToUpper()
    $customobject | Add-Member -MemberType NoteProperty -Name 'IsValid' -Value $ispresent
    $customobject | Add-Member -MemberType NoteProperty -Name 'TimeScanned' -Value (get-date -UFormat “%Y-%m-%d %H:%M:%S”)

    $array = $array + $customobject


    $i++

}

Write-Host "$totalaccounts accounts scanned"

$array.GetEnumerator() | Format-Table -AutoSize
$array | Export-Csv -NoTypeInformation -Force "D:\SEID\Admins\JLC\Coding\PowerShell\Accounts-Scanned-$i-$(get-date -UFormat “%Y-%m-%d").csv"