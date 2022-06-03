#Variables
$account = ""
$accountlist = "" 
$array = @()
$i = 0

#Get list of accounts
$accountlist = Get-Content -Path D:\SEID\Admins\JLC\Coding\PowerShell\Account-Status.txt

$totalaccounts = $accountlist.count

Foreach ($account in $accountlist)
    {

        #Parse samaccountname and domainname suffix from UPN
        #$address = ""
        $Name=$account.Split("@")[0]
        $Name
        $Domain=$account.Split("@")[1]
        $Domain

        #Get account info using samaccountname and domainname
        Get-ADUser -Identity "$name" -Server $domain | Out-File "D:\SEID\Admins\JLC\Coding\PowerShell\RemovedAccountsLog-$(get-date -UFormat “%Y-%m-%d").txt" -Encoding ASCII -Append

        $i++

}

Write-Host "$i accounts scanned"