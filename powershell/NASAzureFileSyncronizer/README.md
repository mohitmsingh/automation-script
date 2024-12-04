# NASAzureFileSyncronizer (Sync NAS(OnPrem) to VM to Azure Cloud)

### 1.1	Assumption & Limitation

i.	Between OnPrem VM to NAS, Robocopy is in place without /MIR i.e. Copy paste is happening between those endpoints, due to which anything deleted from Azure File Share will never be deleted from NAS.

ii.	Intentional & Adjustable Delay has been added between Azure  File Share to OnPrem VM to avoid any potential data/file loss

iii.	Below diagram is the logical plan of the solution

<img src="./images/Picture1.png">

iv.	Consideration on the Solution techm has provided:
1.	Azure Storage Sync Service will take care of syncing from Windows Server (On Prem) to Azure file share by services, so we have not added any code in the main script to handle that.
2.	CSV will be the only input file to the main script
3.	For multiple NAS connection, please add input file to the main script
So based on that the task scheduler frequency to run should be around every 10min.
4.	We have added a mechanism to capture the logs on specific path which will be shared in the SOP document.

### 1.2	Step 1 - Provide Input using CSV file [One Time Activity]

i.	Download the Tool Zip Package (https://github.com/BasicCloudTech/PowershellAutomation/raw/main/NASAzureFileSyncronizer/NASAzureFileSyncronizer.zip) to specific VM where we have storage sync service installed onto D: Drive and extract the file there:
<img src="./images/Picture2.png"/>

ii.	Navigate to Path D:\NASAzureFileSyncronizer\Script, and copy Input.csv file on your local machine for modification (for better visual on the data)

<img src="./images/Picture3.png"/>

<img src="./images/Picture4.png"/>

| **Header**                     | **Header Value**  | **Explanation** |
| ------------------------------| --------------------------------------------------------------------------| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **srno**                       | NAS1, NAS2                                                                  | Serial No.     *                                                                                             |
| **ennv**                       | Example: dev, sit, uat, prd                                                 | Environment Name  |
| **nasMachineUserName**         | [Should be encrypted] <br> corp-aisXXXdev\\nas_nwf1, <br> corp-aisXXXdev\\nas_nwf2 | Username of NAS Machine Login should be encrypted using EncryptDecrypt Tool [Step 2 - Encrypt Confidential Value One Time Activity](https://github.com/BasicCloudTech/PowershellAutomation/tree/main/NASAzureFileSyncronizer#13step-2---encrypt-confidential-value-one-time-activity) |
| **nasMachinePwd**              | [Should be encrypted] <br> Password@1,Password@2 | Username of NAS Machine Login should be encrypted using EncryptDecrypt Tool [Step 2 - Encrypt Confidential Value One Time Activity](https://github.com/BasicCloudTech/PowershellAutomation/tree/main/NASAzureFileSyncronizer#13step-2---encrypt-confidential-value-one-time-activity) |
| **inputNASPath**               | \\\\10.137.XX.X\\sht_sdwf                                                   | NAS Path which needs to be mapped as drive. It should be in same format  |
| **inputOnPremPath**            | D:\\sht_sbnwf                                                               | On Prem Path (windows server) where the script has been copied    |
| **inputParentFolder**          | \\DEV\\DATA\\ | NAS **Parent** **Folder should be added here** example: <br> \\DEV\\DATA1\\ belongs to **NAS1** <br> \\STG\\DATA2\\ belongs to  **NAS2** |
| **inputFolderReadWriteAccess** | FolderName1,FolderName2   | SubFolder Name which needs to be copied from NAS to Azure & Azure to NAS |
| **inputFolderReadOnly**        | FolderName1,FolderName2 | SubFolder Name which needs to be copied from NAS to Azure Only |
| **inputFolderWriteOnly**       | FolderName1,FolderName2 | SubFolder Name which needs to be copied from Azure to NAS Only |
| **rgName**                     | Example: rg-AppName-az-region-dev-001 | Assumption: the value will be same for all NAS to a particular environment. <br> Get the value from Azure side, Resource Group of storage sync service used for this environment  |
| **StorageSyncServiceName**     | Example:sss-appname-az-region-dev-001 | Assumption: the value will be same for all NAS to a particular environment.Get the value from Azure side, Storage Sync Service used for this environment |
| **SyncGroupName**  | Example: appname-syncgroup1-dev | Assumption: the value will be same for all NAS to a particular environment.Get the value from Azure side, the Sync Group Name used for this from the Storage Sync Service.|
| **CloudEndpointName** | [Should be encrypted] Example: 112b9026-XXXX-XXXX-XXXX-0e70e17aaf64 | Assumption: the value will be same for all NAS to a particular environment. Get the value from Azure side, Cloud Endpoint created for Sync group of storage sync service used for this environment [Step 2 - Encrypt Confidential Value One Time Activity](https://github.com/BasicCloudTech/PowershellAutomation/tree/main/NASAzureFileSyncronizer#13step-2---encrypt-confidential-value-one-time-activity) |

iii.	Once the changes are made to input.csv, copy back the input file from local machine to OnPrem Path
D:\NASAzureFileSyncronizer\Script

<img src="./images/Picture5.png"/>

### 1.3	Step 2 - Encrypt Confidential Value [One Time Activity]

i.	Go to EncryptDecryptTool, on path you have copied the zip file to and that specific Path, navigate to D:\NASAzureFileSyncronizer\EncryptDecryptTool and double click on “Startup.bat”

<img src="./images/Picture6.png"/>

ii.	Encrypt below values to add it in input.csv file.

nasMachineUserName <br> nasMachinePwd <br> CloudEndpointName

<img src="./images/Picture7.png"/>

iii.	Details info from the above image
1.  Choose 1 for Encryption or 2 for decryption of value you are going to pass in next step, press enter
2.  Copy the actual value you want to encrypt/decrypt and paste it here, press enter
3.  For verification Only, Actual Value you passed
4.  For Use, Encrypted Value: is shown in blue. Please COPY the text after “:” without space.

iv.	Copy the encryption value to input.csv file

v.	Post this, 5 encryption files will be generated on the path:

### 1.4	Step 3 – Verify Main PowerShell script (NASAzureFileSyncronizer.ps1)

i.	Navigate to D:\NASAzureFileSyncronizer\Script\NASAzureFileSyncronizer.ps1

<img src="./images/Picture8.png"/>

ii.	Verify the below path is correct

<img src="./images/Picture9.png"/>

iii.	Save the file.

### 1.5	Step 4 – Create & Configure Task Scheduler

i.	Open “Task Scheduler” --> Click on Import Task
ii.	Navigate to path: D:\NASAzureFileSyncronizer\Script\TaskScheduler and 
Select NASAzureFileSyncronizer.xml and import the file to create and configure the task Scheduler.
iii.	Enable the script

<img src="./images/Picture10.png"/>

iv.	You will see the task scheduler under the path \EntApps\NASAzureFileSyncronizer

<img src="./images/Picture11.png"/>

v.	Check for Action and the path, it should map to D:\NASAzureFileSyncronizer\Batch NASAzureFileSyncronizer.bat

<img src="./images/Picture12.png"/>

### 1.6	Step 5 – Logging

Logs generated here for every run D:\NASAzureFileSyncronizer\Script\Logs and housekeeping policy to keep the last is 5 days’ logs only. It also shows how much time will be taken for whole process to complete.

<img src="./images/Picture13.png"/>
