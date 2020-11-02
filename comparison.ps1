Import-Module ActiveDirectory

$Dll = '\\server\install\soft'

$To = '\C$\Program Files\soft'

$SourceFiles = @()

$SourceHashes = @()

Get-ChildItem $Dll | foreach{
        
    $SourceFiles += $_.Name

    $SourceHashes += (Get-FileHash $_.FullName -Algorithm MD5).Hash
            
}

function Copy-Dll($path){

    $DllUpdate = $false

    Get-ChildItem $path | foreach{

        if($SourceFiles.Contains($_.Name)){
            
            $CurrentHash = (Get-FileHash $_.FullName -Algorithm MD5).Hash
            
            if($SourceHashes.Contains($CurrentHash)){
                
                $text = $_.Name + ' обновлён'

                Write-Host $text -ForegroundColor Gray
            
            }else{
                
                $text = $_.Name + ' не обновлён'

                Write-Host $text -ForegroundColor Red

                $DllUpdate = $true

            }
        
        }
    
    }

    if($DllUpdate){
        
        Write-Host 'Запуск обновления DLL'

        Get-ChildItem $Dll | Copy-Item -Destination $path -force -ErrorAction Stop
    
    }else{
    
        Write-Host 'Обновление не требуется' -ForegroundColor Gray
    
    }

}

Get-ADComputer -Filter * -SearchBase 'OU=Computers,DC=testlab,DC=local' | Sort Name| foreach{
    
    if(Test-Connection $_.Name -Count 1 -ErrorAction SilentlyContinue){
        
        Write-Host $_.Name -ForegroundColor Green

        $path = '\\' + $_.Name + $To

        Write-Host $path

        Copy-Dll $path
    
    }else{
    
        Write-Host $_.Name -ForegroundColor Red
    
    }

}
