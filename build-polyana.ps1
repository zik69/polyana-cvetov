# Сборка index.html: подставляет фото в base64 в шаблон.
# Запуск: powershell -ExecutionPolicy Bypass -File .\build-polyana.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$tplPath = Join-Path $root "index.template.html"
$imgPath = Join-Path $root "photo.jpg"
$outPath = Join-Path $root "index.html"

if (-not (Test-Path $tplPath)) { throw "нет index.template.html" }
if (-not (Test-Path $imgPath)) { throw "нет photo.jpg" }

$tpl = Get-Content $tplPath -Raw -Encoding UTF8
$bytes = [IO.File]::ReadAllBytes($imgPath)
$b64 = [Convert]::ToBase64String($bytes)
$html = $tpl.Replace("__PHOTO__", "data:image/jpeg;base64," + $b64)

[IO.File]::WriteAllText($outPath, $html, (New-Object Text.UTF8Encoding($false)))

$info = Get-Item $outPath
"index.html: {0:N0} байт, фото {1:N0} байт base64, маркер остался: {2}" -f $info.Length, $b64.Length, ($html.Contains("__PHOTO__"))
