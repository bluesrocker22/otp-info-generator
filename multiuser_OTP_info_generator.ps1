# This is windows sysadmin's MultiOTP helper
# Use this script for generate file sets for AD users with 2FA settings
# Author: Vitaly Kraselnikov 2023

# Some important variables here
$qrpath = "E:\2FA_project\QR_new"
$adGroupName = "2fausers"
$programpath = "C:\multiotp"

$userName = $null

Write-Host "!!!Welcome to OTPinfoGenerator2000 (multiuser)!!!" -ForegroundColor Magenta
Write-Host ""
Write-Host "Path to generate files: " -nonewline
Write-Host "$qrpath" -ForegroundColor Green
Write-Host "Folder with multiOTP instance: " -nonewline
Write-Host "$programpath"  -ForegroundColor Green
Write-Host ""

if ($args.Length -ne 0) {
  Write-Host "I will use arguments as usernames"
  Write-Host "Please check this list of users: " -NoNewline
  foreach ($arg in $args) {
    Write-Host "$arg" -ForegroundColor Green -NoNewline
    Write-Host ", " -NoNewline
  }
  $confirmation = Read-Host "is this OK? (y/n, default n)"
    if ($confirmation -eq 'y') {
      $confirmation = Read-Host "Syncronize users in AD group ($adGroupName) with internal database before generating? (y/n, default: n)"
      if ($confirmation -eq 'y') {
      Start-Process -FilePath "$programpath\multiotp.exe" -ArgumentList "-ldap-users-sync" -NoNewWindow -Wait
      Write-Host ""
      }
      Write-Host "Started generating filesets"
      foreach ($arg in $args) {
    
        $userName = $arg
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
        $runTime = Get-Date -DisplayHint Time
        Write-Host "$runTime Let's check files in archive " -NoNewline
        Write-Host "$archivename" -ForegroundColor Green
      }
    } else {
      Write-Host "Looks that I couldn’t help you :("
      exit
    }
    $confirmation = Read-Host "Open folder containing the file? (y/n, default: n)"
    if ($confirmation -eq 'y') {
      Invoke-Item $qrpath
    }  

  } else {
        Write-Host "You don't provide any arguments (usernames)... Bye!"
        exit
  }
