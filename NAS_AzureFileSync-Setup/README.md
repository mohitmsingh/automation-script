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
