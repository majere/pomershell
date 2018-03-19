Import-Module ActiveDirectory

$cred = Get-Credential -Credential "seckga\vasiliy"


function DisableUser($Name, [switch]$Seckga){

    if($Seckga){
    
        #it's seckga
        Write-Host "Выключение пользователя в домене seckga"
        $SamAccountName = (Get-ADUser -Filter {Name -eq $Name} -Server seckga.local -Credential $cred -SearchBase "OU=ГУ НИПЦ (gu_nipc),DC=seckga,DC=local").SamAccountName
        
        if($SamAccountName){
        
            Disable-ADAccount -Server seckga.local -Credential $cred $SamAccountName
        
        }else{
        
            Write-Host "Нет учётной записи в домене seckga" -ForegroundColor Gray
        
        }
        
    
    }else{
        
        #it's genplan
        Write-Host "Выключение пользователя в домене genplan"
        $SamAccountName = (Get-ADUser -Filter {Name -eq $Name} -SearchBase "OU=users and computers,DC=genplan,DC=local").SamAccountName
        
        if($SamAccountName){
        
            Disable-ADAccount $SamAccountName
        
        }else{
        
            Write-Host "Нет учётной записи в домене genplan" -ForegroundColor Gray
        
        }
        
    }
}



function DeleteMail($Name, [switch]$Seckga){

    if($Seckga){
    
        #it's seckga
        
        Write-Host "Удаление контакта пользователя в домене seckga"
        $SamName = (Get-ADUser -Filter {Name -eq $Name} -Server seckga.local -Credential $cred -SearchBase "OU=ГУ НИПЦ (gu_nipc),DC=seckga,DC=local").SamAccountName
        $SamName = $SamName + "*"
        $session = New-PSSession -Credential $cred  -ConfigurationName Microsoft.Exchange -ConnectionUri "http://exch.seckga.local/PowerShell" -Authentication Kerberos
        Import-PSSession $session -CommandName Remove-MailContact, Disable-Mailbox, Remove-TransportRule -AllowClobber
        Remove-MailContact $SamName -Confirm:$false

        Write-Host "Выключение почтового ящика в домене seckga"
        Disable-Mailbox $Name -Confirm:$false

        Write-Host "Удаление правила транспорта"
        Remove-TransportRule $SamName -Confirm:$false
    
        Remove-PSSession $session
    
    }else{
    
        #it's genplan

        Write-Host "Удаление контакта пользователя в домене genplan"
        $session = New-PSSession  -ConfigurationName Microsoft.Exchange -ConnectionUri "http://exchange.genplan.local/PowerShell" -Authentication Kerberos
        Import-PSSession $session -CommandName Remove-MailContact, Disable-Mailbox -AllowClobber
        Remove-MailContact $Name -Confirm:$false

        Write-Host "Выключение почтового ящика в домене genplan"
        Disable-Mailbox $Name -Confirm:$false
    
        Remove-PSSession $session
    }
}


function SearchUser($Name, [switch]$Seckga){

    $name = "*" + $name +  "*"

    $userArray = @()

    if($Seckga){

        Write-host "Поиск в домене seckga" -ForegroundColor Gray
    
        $GetAD = Get-ADUser -Filter {(Name -like $name) -and (Enabled -eq $true)} -Server seckga.local -Credential $cred -SearchBase "OU=ГУ НИПЦ (gu_nipc),DC=seckga,DC=local" 

    }else{

        Write-host "Поиск в домене genplan" -ForegroundColor Gray
    
        $GetAD = Get-ADUser -Filter {(Name -like $name) -and (Enabled -eq $true)} -SearchBase "OU=users and computers,DC=genplan,DC=local"
    
    }
    
    foreach($obj in $GetAD){
    
        $userArray += $obj.Name
    
    }
    
    return ,$userArray

}





Write-Host "Введите фамилию сотрудника:" -ForegroundColor Green

$name = Read-Host 

if($name){
    
    $found = $true

    $answer = SearchUser -Name $name

    if($answer.Length -eq 0){

        $answer = SearchUser -Name $name -Seckga

        if($answer.Length -eq 0){
    
            Write-Host "Не найдено пользователя" -ForegroundColor Red

            $found = $false

        }

    }

    if($found){

        Write-Host "Найдены следующие пользователи:" -foreground Gray

        $count = 0

        $answer | foreach {

            Write-Host $count $_
    
            $count ++
        }

        Write-Host "Выберите номер сотрудника, которого требуется отключить:" -ForegroundColor Green

        $numUser = Read-Host

            if($numUser){

                Write-Host "Вы действительно хотите отключить УЗ пользователя и удалить контакты? [Y/N][Д/Н]" -ForegroundColor Green

                $confirm = Read-Host

                If($confirm -eq "y" -or $confirm -eq "д"){
            
                
                    Write-Host "Выключение учетных записей пользователя " -NoNewline -ForegroundColor Gray

                    Write-Host $answer[$numUser]
                
                                
                    DisableUser -Name $answer[$numUser]

                    DisableUser -Name $answer[$numUser] -Seckga

                    DeleteMail -Name $answer[$numUser]

                    DeleteMail -Name $answer[$numUser] -Seckga

            
                }else{
            
                    Write-Host "Отмена анигиляции"
                
                }

            }
        }
    
}else{
    
    Write-Host "Не введено имя пользователя" -ForegroundColor Red

}
