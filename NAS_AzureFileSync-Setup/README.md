# EncryptDecryptTool_1v

- 1.1	Assumption & Limitation

i.	Between OnPrem VM to NAS, Robocopy is in place without /MIR i.e. Copy paste is happening between those endpoints, due to which anything deleted from Azure File Share will never be deleted from NAS.

ii.	Intentional & Adjustable Delay has been added between Azure  File Share to OnPrem VM to avoid any potential data/file loss

iii.	Below diagram is the logical plan of the solution
