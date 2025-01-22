try{
    $BitLockerVolume = Get-BitLockerVolume -MountPoint $env:SystemDrive
    $KeyProtectorId=""

    foreach($keyProtector in $BitLockerVolume.KeyProtector){
        if($keyProtector.KeyProtectorType -eq "RecoveryPassword"){
            $KeyProtectorId=$keyProtector.KeyProtectorId
            break;
        }
    }

    $result = BackupToAAD-BitLockerKeyProtector -MountPoint "$($env:SystemDrive)" -KeyProtectorId $KeyProtectorId

    return $true
}
catch{
    return $false
}