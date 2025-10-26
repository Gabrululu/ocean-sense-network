# PowerShell script para deploy en Starknet
# Ocean-Sense Network

Write-Host "🌊 Ocean-Sense Network - Deploy a Starknet" -ForegroundColor Cyan
Write-Host ""

# Verificar Scarb
try {
    $scarbVersion = scarb --version
    Write-Host "✅ Scarb encontrado: $scarbVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Scarb no está instalado" -ForegroundColor Red
    Write-Host "Instala desde: https://docs.swmansion.com/scarb/"
    exit 1
}

# Verificar Starkli
try {
    $starkliVersion = starkli --version
    Write-Host "✅ Starkli encontrado: $starkliVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Starkli no está instalado" -ForegroundColor Red
    Write-Host "Instala con: cargo install starkli"
    exit 1
}

# Navegar a contratos
Set-Location contracts

# Compilar
Write-Host ""
Write-Host "📦 Compilando contrato..." -ForegroundColor Yellow
scarb build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al compilar" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Compilado correctamente" -ForegroundColor Green

# Verificar archivo compilado
if (-not (Test-Path "target/dev/buoy_registry.sierra.json")) {
    Write-Host "❌ Archivo compilado no encontrado" -ForegroundColor Red
    exit 1
}

# Deploy
Write-Host ""
Write-Host "🚀 Deployando a Starknet Sepolia..." -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANTE: Necesitas tener configurada una cuenta:" -ForegroundColor Yellow
Write-Host "  starkli account new --account ocean-sense" -ForegroundColor Cyan
Write-Host ""
Write-Host "Y necesitas ETH en Sepolia (faucet)" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "¿Continuar? (y/n)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    exit 0
}

# Declarar contrato
Write-Host "🔍 Declarando contrato..." -ForegroundColor Yellow
$declareOutput = starkli declare target/dev/buoy_registry.sierra.json `
  --account ocean-sense `
  --rpc https://starknet-sepolia.public.blastapi.io

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al declarar" -ForegroundColor Red
    exit 1
}

# Extraer Class Hash
$classHashLine = $declareOutput | Select-String "class_hash"
$classHash = if ($classHashLine) {
    ($classHashLine -split "class_hash:\s*")[1].Trim()
} else {
    Read-Host "Introduce el Class Hash"
}

Write-Host "✅ Declarado. Class Hash: $classHash" -ForegroundColor Green

# Deploy
Write-Host ""
Write-Host "📝 Deployando instancia..." -ForegroundColor Yellow
$deployOutput = starkli deploy $classHash `
  --account ocean-sense `
  --rpc https://starknet-sepolia.public.blastapi.io

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al deployar" -ForegroundColor Red
    exit 1
}

# Extraer Contract Address
$contractLine = $deployOutput | Select-String "contract_address"
$contract = if ($contractLine) {
    ($contractLine -split "contract_address:\s*")[1].Trim()
} else {
    Read-Host "Introduce el Contract Address"
}

Write-Host "✅ Deployado. Contrato: $contract" -ForegroundColor Green

# Guardar en .env
Set-Location ../backend

$envContent = @"
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
STARKNET_CONTRACT_ADDRESS=$contract
STARKNET_NETWORK=sepolia
PORT=3001
"@

Out-File -FilePath .env -InputObject $envContent -Encoding UTF8

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✅ DEPLOY COMPLETO" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Contrato desplegado en:" -ForegroundColor Green
Write-Host "  Sepolia: https://sepolia.starkscan.co/contract/$contract" -ForegroundColor Cyan
Write-Host "  Voyager: https://sepolia.voyager.online/contract/$contract" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dirección guardada en: backend/.env" -ForegroundColor Yellow
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Configurar SUPABASE_URL y SUPABASE_ANON_KEY en backend/.env"
Write-Host "2. Ejecutar: cd backend && npm install && npm run dev"
Write-Host "3. Abrir: frontend/dashboard.html en navegador"
Write-Host ""

