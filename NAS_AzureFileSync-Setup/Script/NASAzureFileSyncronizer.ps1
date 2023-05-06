########################Inputs################################################

$csvPath = "D:\NAS_AzureFileSync-Setup_5v\Script\Input.csv"
$logPath = "D:\NAS_AzureFileSync-Setup_5v\Script\Logs"

#############################################################################

#[Log Capture]###############################################################
Function Log-Message()
{
 param
    (
    [Parameter(Mandatory=$true)] [string] $Message
    )
 
    Try {
        #Get the current date
        $LogDate = (Get-Date).tostring("yyyyMMdd")
 
        #Get the Location of the script
        If ($psise) {
            $CurrentDir = Split-Path $psise.CurrentFile.FullPath
        }
        Else {
            $CurrentDir = $Global:PSScriptRoot
        }
 
        #Frame Log File with Current Directory and date
        $LogFile = $CurrentDir+ "\Logs\Log-" + $LogDate + ".log"
 
        #Add Content to the Log File
        $TimeStamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss:fff tt")
        $Line = "$TimeStamp - $Message"
        Add-content -Path $Logfile -Value $Line
 
        Write-host "Message: $Message"
    }
    Catch {
        Write-host -f Red "Error:" $_.Exception.Message 
    }
}

#[MainScript]############################################################################
$csv = Import-CSV $csvPath | ForEach-Object {
    
    #[VARIABLES-NAS LOGIN]########################################
	[Byte[]]$key = (1..32) #256-bit key (32 bytes) lengths reference https://www.pdq.com/blog/secure-password-with-powershell-encrypting-credentials-part-2/
    $EncryptedData = $($_.nasMachineUserName)
    $nasMachineUserName = ConvertTo-SecureString $EncryptedData -key $key
    $nasMachineUserName = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($nasMachineUserName))
    $EncryptedData = $($_.nasMachinePwd)
    $nasMachinePwd = ConvertTo-SecureString $EncryptedData -key $key
    $cred = New-Object System.Management.Automation.PSCredential $nasMachineUserName,$nasMachinePwd

    #[VARIABLES-NAS DETAILS]########################################
	$nascount = $($_.srno)
    $naspath = $($_.inputNASPath)
    $onpremPath = $($_.inputOnPremPath)
    $inputParentFolder = $($_.inputParentFolder)
    
    $inputFolderWriteAccess = $($_.inputFolderWriteAccess)
    $inputFolderWriteAccess = $inputFolderWriteAccess.Split(",")

    $inputFolderReadOnly = $($_.inputFolderReadOnly)
    $inputFolderReadOnly = $inputFolderReadOnly.Split(",")

    #[VARIABLES-AZURE SYNC GROUP DETAILS]########################################
    $rgName = $($_.rgName) #resource group
    $StorageSyncServiceName = $($_.StorageSyncServiceName)
    $SyncGroupName = $($_.SyncGroupName)

    $EncryptedData = $($_.CloudEndpointName)
    $CloudEndpointName = ConvertTo-SecureString $EncryptedData -key $key
    $CloudEndpointName = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($CloudEndpointName))
 
    Log-Message "[$nascount][BEGIN]XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    Log-Message "NASPath: $naspath "
    Log-Message "OnPremPath: $onpremPath "
    Log-Message "ParentFolder: $inputParentFolder "
    Log-Message "WriteOnly Folder to Sync: $inputFolderWriteAccess "
    Log-Message "ReadOnly Folder to Sync: $inputFolderReadOnly "
    #[Stage1]Mounting NAS System as X drive
    New-PSDrive -Name "X" -Root $naspath -Persist -PSProvider "FileSystem" -Credential $cred
    Log-Message "Mounted $naspath path to temporary Drive X"

    #[Stage2]Copy folder from NAS to On-Prem Machine
    Log-Message "[NAS Server $naspath ----> Azure FileShare - SYNC BEGIN]"
    if (!$inputFolderReadOnly) { $inputFolderToSync1 = $inputFolderWriteAccess } 
    else { $inputFolderToSync1 = $inputFolderWriteAccess + $inputFolderReadOnly }
    Log-Message "FoldertoSync to AzureFileShare: $inputFolderToSync1 "
    foreach ($folder in $inputFolderToSync1)
    {
        $mainSource = "$inputParentFolder$folder"
        
        if (Test-Path -Path "X:$mainSource")
        {
            try {

                robocopy X:$mainSource "$onpremPath$mainSource" /MT:20 /R:2 /W:1 /B /MIR /IT /COPY:DATSO /DCOPY:DAT /NP /NFL /NDL /XD "System Volume Information" /UNILOG:$logPath\robocopy_$folder.log
                Log-Message "$folder synced to $onpremPath$mainSource"
                
                $files = Get-ChildItem -LiteralPath "$onpremPath$mainSource" -Recurse
                Foreach ($file in $files){
                    $path = $file.FullName
                    $ACL = Get-ACL -Path $path
                    $AccessRule = ""
                    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","Allow")
                    $ACL.SetAccessRule($AccessRule)
                    $ACL | Set-Acl -Path $path
                    }
                
                $mainSource = ""
            }
            catch
            {
                Write-host -f Red "Error:" $_.Exception.Message 
            }
            
        }

    }
    #[Stage3] Azure AutoSync will sync files from OnPrem to AzureFileshare

    Log-Message "[NAS Server $naspath ----> Azure FileShare - SYNC END]"
    Start-Sleep -Seconds 20 #20 sec

    
    #[Stage4]Sync Azure Fileshare to On Prem Machine (Sync Folder)
    Log-Message "[Azure FileShare ----> NAS Server $naspath - SYNC BEGIN]"
    Invoke-AzStorageSyncChangeDetection -ResourceGroupName $rgName -StorageSyncServiceName $StorageSyncServiceName -SyncGroupName $SyncGroupName -CloudEndpointName $CloudEndpointName
    Start-Sleep -Seconds 60 #1 min
    Log-Message "Azure Fileshare ----> On Prem Server - Completed !"

    #[Stage5]Copy folder from On Prem Machine to NAS Server
    $inputFolderToSync2 = $inputFolderWriteAccess
    Log-Message "FoldertoSync to NAS: $inputFolderToSync2 "
    foreach ($folder in $inputFolderToSync2)
    {
        $mainSource = "$inputParentFolder$folder"
 
        $files = Get-ChildItem -LiteralPath "$onpremPath$mainSource" -Recurse
        Foreach ($file in $files)
        {
            $path = $file.FullName
            $ACL = Get-ACL -Path $path
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","Allow")
            $ACL.SetAccessRule($AccessRule)
            $ACL | Set-Acl -Path $path
        }
        Start-Sleep -Seconds 3
        robocopy "$onpremPath$mainSource" "X:$mainSource" /MT:20 /R:2 /W:1 /B /MIR /IT /COPY:DATSO /DCOPY:DAT /NP /NFL /NDL /XD "System Volume Information" /UNILOG:$logPath\robocopy_$folder.log
        Log-Message "$folder sync to X:$mainSource - Completed !"
        $mainSource = ""
    }
    Start-Sleep -Seconds 15 #15 seconds
    Log-Message "[Azure FileShare ----> NAS Server $naspath - SYNC END]"

    #[Stage5]Unmounting the X:/drive
    net use X: /delete
    Log-Message "Unmount temporary drive"
    Log-Message "[$nascount][ENDS]XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    Write-host "Logs captured at $LogFile"
    #[Stage6]HouseKeepingPolicy of logs #delete logs older that 5 days
    Get-ChildItem -Path $logPath -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-5))} | Remove-Item
}
$csv