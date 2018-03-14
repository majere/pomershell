function PowerOffMachines($server, $user, $password, [switch]$force){
    
    $pass = $password | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass
    Connect-VIServer -Credential $cred $server

    if(!$force){
        Get-VM | foreach{
            if($_.PowerState -eq "PoweredOn"){
                if($_.Guest.State -ne "Running"){
                    Write-Host $_.Name "Suspend" -ForegroundColor Blue
                    Suspend-VM $_.Name -RunAsync
                }else{
                    Write-Host $_.Name "Shutdown guest" -ForegroundColor Green
                    Shutdown-VMGuest $_.Name -RunAsync
                }
            }
        }
    }else{
        Get-VM | foreach{
            if($_.PowerState -eq "PoweredOn"){
                Write-Host $_.Name "POWER OFF" -ForegroundColor Red
                Stop-VM $_.Name -RunAsync
            }
        }
    }
        
    Disconnect-VIServer -server $server -Confirm:$false -force

    Write-Host " "

}

function ShutdownESXiHost($server, $user, $password){

    $pass = $password | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass
    Connect-VIServer -Credential $cred $server
    Write-Host "Выключение ESXi хоста" $server -ForegroundColor Red
    Stop-VMHost $_.Name -RunAsync
}

$confirm = Read-Host "Данный скрипт погасит все виртуальные машины и хосты. Если вы действительно хотите выключить все машины, то введите POWER OFF"

if($confirm -eq "POWER OFF"){

    Write-Host "Adventure time!"

    Import-Module VMware.PowerCLI

    PowerOffMachines -server 192.168.0.138 -user "qqq" -password "123"
    PowerOffMachines -server 192.168.0.139 -user "qqq" -password "123"
    PowerOffMachines -server 192.168.0.140 -user "qqq" -password "123"
    PowerOffMachines -server 192.168.0.21 -user "qqq" -password "123"
    PowerOffMachines -server 192.168.0.22 -user "qqq" -password "123"
    PowerOffMachines -server 192.168.0.4 -user "qqq" -password "123"

    Write-host "Ожидание безопасного выключения машин 3 минуты"

    Start-Sleep 180

    Write-Host "Принудительное выключение машин"
123
    PowerOffMachines -server 192.168.0.138 -user "qqq" -password "123" -force
    PowerOffMachines -server 192.168.0.139 -user "qqq" -password "123" -force
    PowerOffMachines -server 192.168.0.140 -user "qqq" -password "123" -force
    PowerOffMachines -server 192.168.0.21 -user "qqq" -password "123" -force
    PowerOffMachines -server 192.168.0.22 -user "qqq" -password "123" -force
    PowerOffMachines -server 192.168.0.4 -user "qqq" -password "123" -force

    Write-host "Ожидание выключения машин 1 минуту"

    Start-Sleep 60

    Write-Host "Выключение ESXI хостов"

    ShutdownESXiHost -server 192.168.0.138 -user "qqq" -password "123"
    ShutdownESXiHost -server 192.168.0.139 -user "qqq" -password "123"
    ShutdownESXiHost -server 192.168.0.140 -user "qqq" -password "123"
    ShutdownESXiHost -server 192.168.0.21 -user "qqq" -password "123"
    ShutdownESXiHost -server 192.168.0.22 -user "qqq" -password "123"
    ShutdownESXiHost -server 192.168.0.4 -user "qqq" -password "123"

}else{

    Write-Host "no adventure" $confirm
    
}

Write-Host "Скрипт закончил работу. Можно закрыть окно" -ForegroundColor Gray

Start-Sleep 600
