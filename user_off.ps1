Import-Module ActiveDirectory

$cred = Get-Credential -Credential "seckga\vasiliy"


function DisableUser($Name, [switch]$Seckga){

    if($Seckga){
    
        #it's seckga
        Write-Host "���������� ������������ � ������ seckga"
        $SamAccountName = (Get-ADUser -Filter {Name -eq $Name} -Server seckga.local -Credential $cred -SearchBase "OU=�� ���� (gu_nipc),DC=seckga,DC=local").SamAccountName
        Disable-ADAccount -Server seckga.local -Credential $cred $SamAccountName
    
    }else{
        
        #it's genplan
        Write-Host "���������� ������������ � ������ genplan"
        $SamAccountName = (Get-ADUser -Filter {Name -eq $Name} -SearchBase "OU=users and computers,DC=genplan,DC=local").SamAccountName
        Disable-ADAccount $SamAccountName
    }
}



function DeleteMail($Name, [switch]$Seckga){

    if($Seckga){
    
        #it's seckga
        
        Write-Host "�������� �������� ������������ � ������ seckga"
        $SamName = (Get-ADUser -Filter {Name -eq $Name} -SearchBase "OU=users and computers,DC=genplan,DC=local").SamAccountName
        $Samname = $SamName + "*"
        $session = New-PSSession -Credential $cred  -ConfigurationName Microsoft.Exchange -ConnectionUri "http://exch.seckga.local/PowerShell" -Authentication Kerberos
        Import-PSSession $session -CommandName Remove-MailContact, Disable-Mailbox, Remove-TransportRule -AllowClobber
        Remove-MailContact $SamName -Confirm:$false

        Write-Host "���������� ��������� ����� � ������ seckga"
        Disable-Mailbox $Name -Confirm:$false

        Write-Host "�������� ������� ����������"
        Remove-TransportRule $SamName -Confirm:$false
    
        Remove-PSSession $session
    
    }else{
    
        #it's genplan

        Write-Host "�������� �������� ������������ � ������ genplan"
        $session = New-PSSession  -ConfigurationName Microsoft.Exchange -ConnectionUri "http://exchange.genplan.local/PowerShell" -Authentication Kerberos
        Import-PSSession $session -CommandName Remove-MailContact, Disable-Mailbox -AllowClobber
        Remove-MailContact $Name -Confirm:$false

        Write-Host "���������� ��������� ����� � ������ genplan"
        Disable-Mailbox $Name -Confirm:$false
    
        Remove-PSSession $session
    }
}


function SearchUser($Name, [switch]$Seckga){

    $name = "*" + $name +  "*"

    $userArray = @()

    if($Seckga){

        Write-host "����� � ������ seckga" -ForegroundColor Gray
    
        $GetAD = Get-ADUser -Filter {(Name -like $name) -and (Enabled -eq $true)} -Server seckga.local -Credential $cred -SearchBase "OU=�� ���� (gu_nipc),DC=seckga,DC=local" 

    }else{

        Write-host "����� � ������ genplan" -ForegroundColor Gray
    
        $GetAD = Get-ADUser -Filter {(Name -like $name) -and (Enabled -eq $true)} -SearchBase "OU=users and computers,DC=genplan,DC=local"
    
    }
    
    foreach($obj in $GetAD){
    
        $userArray += $obj.Name
    
    }

    return ,$userArray

}



Write-Host "������� ������� ����������:" -ForegroundColor Green

$name = Read-Host 

if($name){

    $answer = SearchUser -Name $name

    if($answer.Length -eq 0){

        $answer = SearchUser -Name $name -Seckga

        if($answer.Length -eq 0){
    
            Write-Host "�� ������� ������������" -ForegroundColor Red

        }

    }else{

        Write-Host "������� ��������� ������������:" -foreground Gray

        $count = 0

        $answer | foreach {

            Write-Host $count $_
    
            $count ++
        }

        Write-Host "�������� ����� ����������, �������� ��������� ���������:" -ForegroundColor Green

        $numUser = Read-Host

            if($numUser){

                Write-Host "�� ������������� ������ ��������� �� ������������ � ������� ��������? [Y/N][�/�]" -ForegroundColor Green

                $confirm = Read-Host

                If($confirm -eq "y" -or $confirm -eq "�"){
            
                
                    Write-Host "���������� ������� ������� ������������ " -NoNewline -ForegroundColor Gray

                    Write-Host $answer[$numUser]
                
                                
                    DisableUser -Name $answer[$numUser]

                    DisableUser -Name $answer[$numUser] -Seckga

                    DeleteMail -Name $answer[$numUser]

                    DeleteMail -Name $answer[$numUser] -Seckga

            
                }else{
            
                    Write-Host "������ ����������"
                
                }

            }

    }
}else{
    
    Write-Host "�� ������� ��� ������������" -ForegroundColor Red

}