 #Get-SCCMAdvertisedPatchesAndInstall.ps1
 #Copied from https://docs.microsoft.com/en-us/answers/questions/642405/powershell-loop-install-of-available-software-upda.html
 
 Add-Type -AssemblyName PresentationCore, PresentationFramework
    
 switch (
   [System.Windows.MessageBox]::Show(
     'This action will download and install critical Microsoft updates and may invoke an automatic reboot. Do you want to continue?',
     'WARNING',
     'YesNo',
     'Warning'
   )
 ) {
  'Yes' 
  {
 Start-Process -FilePath "C:\Windows\CCM\ClientUX\scclient.exe" "softwarecenter:Page=InstallationStatus"
 $installUpdateParam = @{
         NameSpace = 'root/ccm/ClientSDK'
         ClassName = 'CCM_SoftwareUpdatesManager'
         MethodName = 'InstallUpdates'
     }
    
     $getUpdateParam = @{            
         NameSpace = 'root/ccm/ClientSDK'
         ClassName = 'CCM_SoftwareUpdate'
         Filter = 'EvaluationState < 8'
     }       
    
     [ciminstance[]]$updates = Get-CimInstance @getUpdateParam
        
     if ($updates) {
         Invoke-CimMethod @installUpdateParam  -Arguments @{ CCMUpdates = $updates } 
            
         while(Get-CimInstance @getUpdateParam){
             Start-Sleep -Seconds 60
         }
     }
    
     $rebootPending = Invoke-CimMethod -Namespace root/ccm/ClientSDK -ClassName CCM_ClientUtilities -MethodName DetermineIfRebootPending
     if ($rebootPending.RebootPending){
         Invoke-CimMethod -Namespace root/ccm/ClientSDK -ClassName CCM_ClientUtilities -MethodName RestartComputer
     }
     'No' 
     #  Exit-PSSession
   }
 }