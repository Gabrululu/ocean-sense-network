#!/bin/bash

# Script de deploy automatizado para Ocean-Sense Network
# Starknet Sepolia

echo "🌊 Ocean-Sense Network - Deploy a Starknet"
echo ""

# Verificar que Scarb está instalado
if ! command -v scarb &> /dev/null; then
    echo "❌ Scarb no está instalado"
    echo "Instala desde: https://docs.swmansion.com/scarb/"
    exit 1
fi

# Verificar que starkli está instalado
if ! command -v starkli &> /dev/null; then
    echo "❌ Starkli no está instalado"
    echo "Instala con: cargo install starkli"
    exit 1
fi

echo "✅ Herramientas encontradas"

# Navegar a contratos
cd contracts

# Compilar
echo ""
echo "📦 Compilando contrato..."
scarb build

if [ $? -ne 0 ]; then
    echo "❌ Error al compilar"
    exit 1
fi

echo "✅ Compilado"

# Verificar que existe el archivo compilado
if [ ! -f "target/dev/buoy_registry.sierra.json" ]; then
    echo "❌ Archivo compilado no encontrado"
    exit 1
fi

# Deploy
echo ""
echo "🚀 Deployando a Starknet Sepolia..."
echo ""
echo "IMPORTANTE: Necesitas tener configurada una cuenta:"
echo "  starkli account new --account ocean-sense"
echo ""
echo "Y necesitas ETH en Sepolia (faucet)"
echo ""
read -p "¿Continuar? (y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Declarar contrato
echo "🔍 Declarando contrato..."
CLASS_HASH=$(starkli declare target/dev/buoy_registry.sierra.json \
  --account ocean-sense \
  --rpc https://starknet-sepolia.public.blastapi.io \
  --json | jq -r '.class_hash')

echo "✅ Declarado. Class Hash: $CLASS_HASH"

# Deploy
echo ""
echo "📝 Deployando instancia..."
CONTRACT=$(starkli deploy $CLASS_HASH \
  --account ocean-sense \
  --rpc https://starknet-sepolia.public.blastapi.io \
  --json | jq -r '.address')

echo "✅ Deployado. Contrato: $CONTRACT"

# Guardar en .env
cd ../backend
if [ -f .env ]; then
    # Actualizar si existe
    sed -i.bak "s|STARKNET_CONTRACT_ADDRESS=.*|STARKNET_CONTRACT_ADDRESS=$CONTRACT|" .env
else
    # Crear nuevo
    echo "STARKNET_CONTRACT_ADDRESS=$CONTRACT" > .env
fi

echo ""
echo "========================================="
echo "✅ DEPLOY COMPLETO"
echo "========================================="
echo ""
echo "Contrato desplegado en:"
echo "  Sepolia: https://sepolia.starkscan.co/contract/$CONTRACT"
echo "  Voyager: https://sepolia.voyager.online/contract/$CONTRACT"
echo ""
echo "Dirección guardada en: backend/.env"
echo ""
echo "Próximos pasos:"
echo "1. Configurar SUPABASE_URL y SUPABASE_ANON_KEY en backend/.env"
echo "2. Ejecutar: cd backend && npm install && npm run dev"
echo "3. Abrir: frontend/dashboard.html en navegador"
echo ""

