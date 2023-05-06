# EncryptDecryptTool_1v

### 1.1	Assumption & Limitation

i.	Between OnPrem VM to NAS, Robocopy is in place without /MIR i.e. Copy paste is happening between those endpoints, due to which anything deleted from Azure File Share will never be deleted from NAS.

ii.	Intentional & Adjustable Delay has been added between Azure  File Share to OnPrem VM to avoid any potential data/file loss

iii.	Below diagram is the logical plan of the solution

<img src="./images/Picture1.png" width="50%"/>

iv.	Consideration on the Solution techm has provided:
1.	Azure Storage Sync Service will take care of syncing from Windows Server (On Prem) to Azure file share by services, so we have not added any code in the main script to handle that.
2.	CSV will be the only input file to the main script
3.	For multiple NAS connection, please add input file to the main script
So based on that the task scheduler frequency to run should be around every 10min.
4.	We have added a mechanism to capture the logs on specific path which will be shared in the SOP document.

### 1.2	Step 1 - Provide Input using CSV file [One Time Activity]

i.	Copy the [Zip File](https://github.com/BasicCloudTech/PowershellAutomation/blob/main/NAS_AzureFileSync-Setup/NAS_AzureFileSync-Setup_5v.zip) to specific VM where we have storage sync service installed onto D: Drive and extract the file there:
<img src="./images/Picture2.png" width="50%"/>

ii.	Navigate to Path D:\NASAzureFileSyncronizer\Script, and copy Input.csv file on your local machine for modification (for better visual on the data)

<img src="./images/Picture3.png" width="50%"/>

<img src="./images/Picture4.png" width="50%"/>

| **Header**                     | **Header Value**                                                            | **Explanation**                                                                                                                                                                                                                                                                                                                                                            |
| ------------------------------ | --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **srno**                       | NAS1, NAS2                                                                  | Serial No.     *                                                                                             |
| **ennv**                       | Example: dev, sit, uat, prd                                                 | Environment Name  |
| **nasMachineUserName**         | [Should be encrypted] <br> corp-aisXXXdev\\nas_nwf1, <br> corp-aisXXXdev\\nas_nwf2 | Username of NAS Machine Login should be encrypted using EncryptDecrypt Tool [Step 2 - Encrypt Confidential Value One Time Activity](https://github.com/BasicCloudTech/PowershellAutomation/tree/main/NAS_AzureFileSync-Setup#12step-1---provide-input-using-csv-file-one-time-activity)|
| **nasMachinePwd**              | [Should be encrypted] <br> Password@1,Password@2 | Username of NAS Machine Login should be encrypted using EncryptDecrypt Tool [Step 2 - Encrypt Confidential Value One Time Activity](https://github.com/BasicCloudTech/PowershellAutomation/tree/main/NAS_AzureFileSync-Setup#12step-1---provide-input-using-csv-file-one-time-activity) |
| **inputNASPath**               | \\\\10.137.XX.X\\sht_sdwf                                                   | NAS Path which needs to be mapped as drive. It should be in same format  |
| **inputOnPremPath**            | D:\\sht_sbnwf                                                               | On Prem Path (windows server) where the script has been copied    |
| **inputParentFolder**          | \\DEV\\DATA\\ | NAS **Parent** **Folder should be added here** example: <br> \\DEV\\DATA1\\ belongs to **NAS1** <br> \\STG\\DATA2\\ belongs to  **NAS2** |
| **inputFolderReadWriteAccess** | FolderName1,FolderName2   | SubFolder Name which needs to be copied from NAS to Azure & Azure to NAS |
| **inputFolderReadOnly**        | FolderName1,FolderName2 | SubFolder Name which needs to be copied from NAS to Azure Only |
| **inputFolderWriteOnly**       | FolderName1,FolderName2 | SubFolder Name which needs to be copied from Azure to NAS Only |
| **rgName**                     | Example: rg-AppName-az-region-dev-001 | Assumption: the value will be same for all NAS to a particular environment. <br> Get the value from Azure side, Resource Group of storage sync service used for this environment  |
| **StorageSyncServiceName**     | Example:

sss-enterpriseapp-az-asse-dev-001                                 | Assumption: the value will be same for all NAS to a particular environment.

Get the value from Azure side, Storage Sync Service used for this environment                                                                                                                                                                                                                 |
| **SyncGroupName**              | Example:

iwf-pcs-syncgroup1-dev                                            | Assumption: the value will be same for all NAS to a particular environment.

Get the value from Azure side, the Sync Group Name used for this from the Storage Sync Service.                                                                                                                                                                                               |
| **CloudEndpointName**          | [Should be encrypted]

Example:

112b9026-XXXX-XXXX-XXXX-0e70e17aaf64       | Assumption: the value will be same for all NAS to a particular environment.

Get the value from Azure side, Cloud Endpoint created for Sync group of storage sync service used for this environment

[Step 2 - Encrypt Confidential Value [One Time Activity]](file:///C:/Users/Asus/Downloads/AIS%20-%20TechMahindra%20-%20Azure%20Infra%20Setup_20230320.docx#_Step_2_-) |