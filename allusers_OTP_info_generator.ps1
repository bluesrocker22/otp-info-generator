# This is windows sysadmin's MultiOTP helper
# Use this script for generate file sets for AD users with 2FA settings
# Author: Vitaly Kraselnikov 2023

$qrpath = "E:\2FA_project\QR_new"
$adGroupName = "2fausers"
$programpath = "C:\multiotp"
$groupMembers = Get-ADGroupMember -Identity $adGroupName | Where-Object { $_.objectClass -eq "user" } | Select-Object -ExpandProperty SamAccountName

Write-Host "!!!Welcome to OTPinfoGenerator2000 (allusers version)!!!" -ForegroundColor Magenta
Write-Host ""
Write-Host "Path to generate files: " -nonewline
Write-Host "$qrpath" -ForegroundColor Green
Write-Host "Folder with multiOTP instance: " -nonewline
Write-Host "$programpath" -ForegroundColor Green
Write-Host ""
Write-Host "Этот скрипт сгенерирует архивы для всех пользователей доменной группы ${adGroupName} и сложит их в ${qrpath}\"
$confirmation = Read-Host "Продолжить? (y/n, default: n)"
if ($confirmation -eq 'y') {

  $confirmation = Read-Host "Syncronize users in AD group ($adGroupName) with internal database before generating? (y/n, default: n)"
  if ($confirmation -eq 'y') {
    Start-Process -FilePath "$programpath\multiotp.exe" -ArgumentList "-ldap-users-sync" -NoNewWindow -Wait
    Write-Host ""
  }

  Write-Host "Генерирую коды"
  foreach ($userName in $groupMembers) {
    $outputQRName = "${userName}_qr.png"
    $outputLinkName = "${userName}_link.txt"
    $outputSeedName = "${userName}_seed.txt"
    New-Item -ItemType Directory -Path "$qrpath\$userName" | Out-Null
    Start-Process -FilePath "$programpath\multiotp.exe" -ArgumentList "-qrcode $userName $qrpath\$userName\$outputQRName" -NoNewWindow
    Start-Process -FilePath "$programpath\multiotp.exe" -NoNewWindow -Wait -ArgumentList "-urllink $userName" -RedirectStandardOutput $qrpath\$userName\$outputLinkName
    $content = Get-Content -Path $qrpath\$userName\$outputLinkName  | Select-Object -Index (0)
    $seeds = $content.ToString().split('&').split('=')[-5]
    Set-Content -Path $qrpath\$userName\$outputSeedName -Value $seeds
    # Comment 3 strings below if you have PowerShell earlier then version 5
      $archivename = "$userName.zip"
      Compress-Archive -Path $qrpath\$userName\* -DestinationPath $qrpath\$archivename
      Remove-Item -LiteralPath "$qrpath\$userName" -Force -Recurse
    Write-Host "$runTime Let's check files in archive " -NoNewline
    Write-Host "$archivename" -ForegroundColor Green
  }
  Write-Host "Если с папкой "$programpath" все в порядке, то файлсеты для пользователей доменной группы "$adGroupName" были сохранены по адресу "$qrpath"\"
  pause
}

else {
Write-Host "Работа скрипта прервана"
exit
}
