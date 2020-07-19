Import-Module ActiveDirectory

$file_to_delete = '\c$\Users\Public\Desktop\corrupted.lnk'

$ou_where_delete = 'OU=Users and Computers,DC=testlab,DC=local'


function Delete-File($path){

    if(Test-Path $path){
        
        Remove-Item -Path $path -Force -Confirm:$False

        if(Test-Path $path){
        
            $text = 'File "' + $path + '" not deleted'

            Write-Host $text -ForegroundColor Yellow
    
        }else{
           
            $text = 'File "' + $path + '" deleted'

            Write-Host $text
    
        }
    
    }else{
    
        $text = 'There is nothing to delete'

        Write-Host $text -ForegroundColor Gray
    
    }

}


Get-ADComputer -Filter * -SearchBase $ou_where_delete | sort Name | foreach{
    
    if(Test-Connection $_.Name -Count 1 -ErrorAction SilentlyContinue){
        
        Write-Host $_.Name -ForegroundColor Green
        
        $file = '\\' + $_.Name + $file_to_delete

        Delete-File $file
       
    }else{
    
        Write-Host $_.Name -ForegroundColor Red
    
    }
    
}
