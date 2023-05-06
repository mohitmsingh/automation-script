
## pass the sme location
$FolderToScanCopy = 'D:\sht_sbnwf\STG'
$Fileshareloc = 'https://stentappazassedev001.file.core.windows.net/test?sv=2021-06-08&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2023-10-17T14:04:30Z&st=2022-10-17T06:04:30Z&spr=https&sig=64xn%2FXifbXKucuUnhcTfrBuhNqQjALy0X7MyXsQyZtE%3D'

##############################################################################################
$files = Get-ChildItem -LiteralPath $FolderToScanCopy -Recurse
Foreach ($file in $files)
{
 $path = $file.FullName
 $path
 $ACL = Get-ACL -Path $path
 $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("sawangcs","FullControl","Allow")
 $ACL.SetAccessRule($AccessRule)
 $ACL | Set-Acl -Path $path
}

#Copy the files to Non Sync Folder
D:\Software\AZ\azcopy.exe copy $FolderToScanCopy --recursive $Fileshareloc --preserve-smb-permissions=true --preserve-smb-info=true
