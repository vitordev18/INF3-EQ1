$ErrorActionPreference = 'Stop'
Set-Location "$PSScriptRoot\..\apps\fiscaliza"

Write-Host '==> pub get' -ForegroundColor Cyan
flutter pub get

Write-Host '==> analyze' -ForegroundColor Cyan
flutter analyze --fatal-infos

Write-Host '==> test' -ForegroundColor Cyan
flutter test

Write-Host 'OK - pronto para PR.' -ForegroundColor Green
