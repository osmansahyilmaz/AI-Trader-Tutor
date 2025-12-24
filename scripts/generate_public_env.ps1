# Master file (contains PUBLIC + SERVER)
$Src = ".env"

# Generated file (PUBLIC only) — safe to pass to Flutter
$Out = ".env.public"

# Whitelist of vars allowed in Flutter
$AllowedRegex = "^(SUPABASE_URL|SUPABASE_ANON_KEY|APP_ENV|DEFAULT_ASSET_CLASS|DEFAULT_TIMEFRAME)="

if (-not (Test-Path $Src)) {
    Write-Error "Error: $Src not found. Please create it from .env.example"
    exit 1
}

Get-Content $Src | Select-String -Pattern $AllowedRegex | ForEach-Object { $_.Line } | Set-Content $Out

Write-Host "Generated $Out from $Src"
