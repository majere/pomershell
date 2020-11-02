Import-Module ActiveDirectory

#Выбор, на какие OU ставить
$destination = 'OU=Проектная группа 1,OU=Бюро градостроительных проектов,OU=Users and Computers,DC=genplan,DC=local'

#что запускать на каждом компьютере
$command = 'powershell -file "\\server\run\powershell\seryankin\install\1c\1c.ps1"'


#функция выполнения команды
function Start-Command($name){
    
    if(Test-Path 'C:\Windows\System32\PsExec.exe'){
        
        $com = 'psexec.exe \\' + $name + ' -s -h -d ' + $command

        Write-Host $com

        cmd.exe /C $com

    }else{
    
        Write-Host 'Требуется скопировать PsExec.exe в папку C:\Windows\System32 для удаленного выполнения команд. И один раз запустить это приложения для принятия лицензии'
    
    }

}


#перебор компьютеров в указанной OU и запуск
Get-ADComputer -Filter * -SearchBase $destination | foreach{

    if(Test-Connection -ComputerName $_.Name -Count 1 -WarningAction SilentlyContinue){
    
        Write-host $_.Name -ForegroundColor Green

        Start-Command $_.Name

    }else{
    
        Write-Host $_.Name -ForegroundColor Red
    
    }

}
