Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -ForegroundColor DarkCyan
Write-Host "" -ForegroundColor DarkCyan
Write-Host "Welcome to Encrypt/Decrypt Tool" -ForegroundColor DarkCyan
Write-Host "" -ForegroundColor DarkCyan
Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -ForegroundColor DarkCyan
Write-Host "" -ForegroundColor DarkCyan
do {
Write-Host " Please choose to perform" -ForegroundColor DarkMagenta
Write-Host " 1 - Encryption Value" -ForegroundColor DarkMagenta
Write-Host " 2 - Decryption Value" -ForegroundColor DarkMagenta
$r = Read-Host -Prompt "Select Value [1 or 2]"
[Byte[]]$key = (1..32) #256-bit key (32 bytes) lengths reference https://www.pdq.com/blog/secure-password-with-powershell-encrypting-credentials-part-2/ 
switch($r){
    1 {
        Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -ForegroundColor DarkYellow
        Write-Host "You Choose Encryption!"
        $presecret = Read-Host -Prompt "Enter value which you want to Encrypt" -AsSecureString
        $EncryptedData = ConvertFrom-SecureString $presecret -Key $key
        $postsecret = ConvertTo-SecureString $EncryptedData -Key $key
        $PlainTextsecret = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($postsecret))
        Write-Host ""
        Write-Host "Actual Value:" $PlainTextsecret 
        Write-Host "Encrypted value:" $EncryptedData -ForegroundColor Blue
        $EncryptedData | clip
        Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -ForegroundColor DarkYellow
        Write-Host "Encrypted value has been copied to clipboard. Please Cltr+V to paste anywhere." -ForegroundColor DarkYellow
        Write-Host ""
        $a = Read-Host -Prompt "Press x key to close or any key to repeat:"
	}
    2 {
        Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -ForegroundColor DarkYellow
        Write-Host "You Choose Decryption!"
        $EncryptedData = Read-Host -Prompt "Enter value which you want to decrypt"
        $secret = ConvertTo-SecureString $EncryptedData -Key $key
        $PlainTextsecret = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret))

        Write-Host ""
        Write-Host "Actual Value:" $EncryptedData 
        Write-Host "Decrypted value:" $PlainTextsecret -ForegroundColor Blue
        Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -ForegroundColor DarkYellow
        Write-Host ""
        $a = Read-Host -Prompt "Press x key to close or any key to repeat:"
    }
}
} until ($a -eq 'x')

