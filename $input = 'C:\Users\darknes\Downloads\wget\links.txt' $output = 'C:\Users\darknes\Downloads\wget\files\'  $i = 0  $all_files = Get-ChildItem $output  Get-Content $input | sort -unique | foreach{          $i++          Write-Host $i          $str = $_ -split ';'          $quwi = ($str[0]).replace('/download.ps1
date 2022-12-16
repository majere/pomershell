$input = 'C:\Users\darknes\Downloads\wget\links.txt'
$output = 'C:\Users\darknes\Downloads\wget\files\'

$i = 0

$all_files = Get-ChildItem $output

Get-Content $input | sort -unique | foreach{
    
    $i++
    
    Write-Host $i
    
    $str = $_ -split ';'
    
    $quwi = ($str[0]).replace('/', '_')
    
    $quwi = $quwi.replace('ÊÓÂÈ', 'КУВИ')
    
    $filePath = $output + $quwi + '.zip'
    
    $link = $str[1]
    
    #Write-Host $quwi
    
    #Write-Host $link
    
    $filename = $quwi + '.zip'

    $exsists = $false

    $all_files | foreach{

        if($filename -eq $_){
        
            $exsists = $true
        
        }
    
    }


    if($exsists){
    
        #Write-Host 'IN ARRAY' -ForegroundColor Yellow
    
    }else{
    
        Write-Host 'NOT IN ARRAY' -ForegroundColor Red

        Invoke-WebRequest -URI $link -OutFile $filePath

        $all_files = Get-ChildItem $output
    
    }
    

}
