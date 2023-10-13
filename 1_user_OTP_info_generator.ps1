# This is windows sysadmin's MultiOTP helper
# Use this script for generate file sets for AD users with 2FA settings
# Author: Vitaly Kraselnikov 2023

# Some important variables here
$qrpath = "E:\2FA_project\QR_new"
$adGroupName = "2fausers"
$programpath = "C:\multiotp"

$userName = $null
$firstIteration = $true

Write-Host "!!!Welcome to OTPinfoGenerator2000!!!" -ForegroundColor Magenta
Write-Host ""
Write-Host "Path to generate files: " -nonewline
Write-Host "$qrpath" -ForegroundColor Green
Write-Host "Folder with multiOTP instance: " -nonewline
Write-Host "$programpath"  -ForegroundColor Green
Write-Host ""

do {
  if ($firstIteration) {
    if ($args.Length -ne 0) {
      $userName = $args[0]
      Write-Host "Using argument as username: " -NoNewline
      Write-Host "$userName" -ForegroundColor Green
    } else {
      $userName = Read-Host "Argument wasn't provided, please enter username for proceed"
        if ($userName -eq "") {
        Write-Host "Sorry, you don't provide necessary information (username)... Bye!"
        exit
        }
    }
  } else {
    $userName = Read-Host "Please enter new username for proceed"
  }
 
  # AD sync confirmation is not needed for the second iteration
  if ($firstIteration) {
    $confirmation = Read-Host "Syncronize users in AD group ($adGroupName) with internal database before generating? (y/n, default: n)"
    if ($confirmation -eq 'y') {
    Start-Process -FilePath "$programpath\multiotp.exe" -ArgumentList "-ldap-users-sync" -NoNewWindow -Wait
    Write-Host ""
    }
  }

  $firstIteration = $false  # Set the flag to false after the first iteration
    
  Write-Host "Generating files for ${userName} is started..."

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
  Write-Host ""
  $runTime = Get-Date -DisplayHint Time
  Write-Host "$runTime Let's check some files in archive " -NoNewline
  Write-Host "$qrpath\$archivename" -ForegroundColor Green
  Write-Host ""
  # Ask the user if they want to run the task again
  $userChoice = Read-Host "Do you want to run the task again with new username? (y/n, default: n)"
  if ($userChoice -eq "y") {
    $userName = $null  # Reset $userName for the next iteration
  }
} while ($userChoice -eq 'y')

$confirmation = Read-Host "Open folder containing the file? (y/n, default: n)"
if ($confirmation -eq 'y') {
  Invoke-Item $qrpath
}

exit