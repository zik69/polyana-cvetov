# Локальный сервер для проверки страницы: http://localhost:8765/
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8765/")
$listener.Start()
Write-Host "serving $root on http://localhost:8765/"
while ($listener.IsListening) {
  try { $ctx = $listener.GetContext() } catch { break }
  $path = $ctx.Request.Url.LocalPath.TrimStart('/')
  if (-not $path) { $path = "index.html" }
  $file = Join-Path $root $path
  if (Test-Path $file -PathType Leaf) {
    $bytes = [IO.File]::ReadAllBytes($file)
    $ctx.Response.ContentType = switch ([IO.Path]::GetExtension($file).ToLower()) {
      ".html" { "text/html; charset=utf-8" }
      ".jpg"  { "image/jpeg" }
      ".png"  { "image/png" }
      ".json" { "application/json; charset=utf-8" }
      default { "application/octet-stream" }
    }
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $ctx.Response.StatusCode = 404
  }
  $ctx.Response.OutputStream.Close()
}
