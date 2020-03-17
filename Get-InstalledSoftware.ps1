function Get-RemoteRegistry($RegPath, $ComputerName){

    $InstalledSoftObj = @()

    $UninstallArray = @()
    
    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$ComputerName)

    $Uninstall = $reg.OpenSubKey($RegPath)

    $Uninstall.GetSubKeyNames() | foreach{

        $UninstallArray += $RegPath + "\\" + $_

    }

    $Uninstall.Close()

    $UninstallArray

    foreach($line in $UninstallArray){
        
        $subkey = $reg.OpenSubKey($line)

        if($subkey.GetValue('DisplayName')){

            $InstalledSoftObj += New-Object -TypeName PSObject -Property @{
            
                DisplayName = $subkey.GetValue('DisplayName')
                InstallDate = $subkey.GetValue('InstallDate')
                InstallLocation = $subkey.GetValue('InstallLocation')
                InstallSource = $subkey.GetValue('InstallSource')
                UninstallString = $subkey.GetValue('UninstallString')
                DisplayVersion = $subkey.GetValue('DisplayVersion')
            
            }
        
        }

        $subkey.Close()
    
    }

    $reg.Close()
    
    return $InstalledSoftObj

}


function Get-InstalledSoftware($ComputerName){

    $32reg = 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall'

    $64reg = 'SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall'

    $InstalledSoftware += Get-RemoteRegistry -RegPath $32reg -ComputerName $ComputerName

    $InstalledSoftware +=Get-RemoteRegistry -RegPath $64reg -ComputerName $ComputerName

    return $InstalledSoftware
}
