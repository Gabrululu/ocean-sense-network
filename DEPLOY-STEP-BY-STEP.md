# 🚀 DEPLOY COMPLETO - Ocean-Sense Network en Starknet

## 📋 LO QUE TENEMOS LISTO

✅ Smart Contract Cairo (`contracts/buoy-contract.cairo`)  
✅ Dashboard HTML funcional  
✅ Backend API con Supabase  
✅ Simulador de boyas  
✅ Datos mock realistas  

## 🎯 QUÉ FALTA HACER PARA DEPLOY EN STARKNET

### 1. INSTALAR HERRAMIENTAS STARKNET

**🪟 Para WINDOWS (tu caso):**

```powershell
# Abrir PowerShell como Administrador

# Opción 1: Usar Scoop (RECOMENDADO)
# 1. Instalar Scoop (si no lo tienes)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# 2. Instalar Scarb
scoop install scarb

# 3. Verificar
scarb --version

# 4. Instalar starkli (alternativa: descargar binario)
scoop install starkli
```

**🐧 Para Linux/Mac:**

```bash
# Instalar Scarb
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh

# Verificar
scarb --version
```

**Si NADA funciona:**

Usa **Remix para Starknet** (online) - https://remix.ethereum.org
- No necesitas instalar nada
- Compila en el navegador
- Deploya directamente

**Ver:** `INSTALL-SCARB-WINDOWS.md` para más opciones

**Tiempo estimado:** 20-30 minutos

### 2. CONFIGURAR WALLET Y CUENTA

```bash
# Crear cuenta en Starknet Sepolia
starkli account new --account ocean-sense

# Te pedirá:
# - Account name: ocean-sense
# - Password: [tu password seguro]
# - Guarda la PRIVATE KEY en lugar seguro

# Ver la dirección pública
starkli account show ocean-sense
# Copia esta dirección: 0x...
```

**Tiempo estimado:** 10 minutos

### 3. OBTENER ETH EN SEPOLIA (FAUCET)

```bash
# Necesitas ETH para gas fees

# Faucet 1: Starknet Foundation
https://faucet.starknet.io/
# Conecta wallet → Selecciona "Sepolia" → Request tokens

# Faucet 2: Starknet Service
https://starknet-faucet.vercel.app/
# Usa tu dirección de cuenta

# Faucet 3: Chainlink
https://faucets.chain.link/sepolia

# Verificar balance
starkli account balance ocean-sense
# Debe mostrar > 0 ETH
```

**Tiempo estimado:** 15 minutos (depende de faucet)

### 4. COMPILAR Y DEPLOY CONTRATO

```bash
cd contracts

# Compilar
scarb build

# Si tienes errores, instalar dependencias:
# Editar Scarb.toml en contracts/
# Agregar: [dependencies.starknet]

# Declarar contrato
starkli declare target/dev/buoy_registry.sierra.json \
  --account ocean-sense \
  --rpc https://starknet-sepolia.public.blastapi.io

# Esto te dará un CLASS_HASH
# Ejemplo: 0x0123456789abcdef...

# Deploy usando el CLASS_HASH
starkli deploy <CLASS_HASH> \
  --account ocean-sense \
  --rpc https://starknet-sepolia.public.blastapi.io

# Esto te dará CONTRACT_ADDRESS
# Ejemplo: 0x0987654321fedcba...
```

**Tiempo estimado:** 30 minutos

### 5. VERIFICAR EN EXPLORER

```bash
# Ver tu contrato en StarkScan
https://sepolia.starkscan.co/contract/<CONTRACT_ADDRESS>

# O en Voyager
https://sepolia.voyager.online/contract/<CONTRACT_ADDRESS>
```

### 6. REGISTRAR PRIMERA BOYA (TEST)

```bash
# Interactuar con el contrato
starkli invoke <CONTRACT_ADDRESS> \
  register_buoy \
  --calldata "BUOY_CALLAO_NORTE" "-1205000" "-7715000" \
  --account ocean-sense \
  --rpc https://starknet-sepolia.public.blastapi.io

# Verificar en explorer que se registró
```

**Tiempo estimado:** 10 minutos

### 7. CONFIGURAR BACKEND PARA USAR CONTRATO

```bash
cd backend

# Crear .env
cat > .env << EOF
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
STARKNET_CONTRACT_ADDRESS=<CONTRACT_ADDRESS>
STARKNET_NETWORK=sepolia
PORT=3001
EOF

# Instalar dependencias
npm install
```

### 8. CONECTAR DASHBOARD CON BACKEND

Editar `frontend/dashboard-data.js`:

```javascript
// Agregar al inicio del archivo
const API_URL = 'http://localhost:3001/api';

// Reemplazar datos mock con llamada a API
async function loadRealData() {
  try {
    const response = await fetch(`${API_URL}/data/realtime`);
    const data = await response.json();
    
    // Actualizar el mapa y UI con datos reales
    buoysData = data;
    renderBuoyList();
    // ... resto del código
  } catch (error) {
    console.error('Error loading data:', error);
  }
}

// Llamar cada 30 segundos
loadRealData();
setInterval(loadRealData, 30000);
```

## 📝 LISTA DE LO QUE FALTA

### OBLIGATORIO PARA DEMO:

- [ ] **Instalar Scarb** (compilador Cairo)
- [ ] **Crear cuenta Starknet**
- [ ] **Obtener ETH de faucet**
- [ ] **Compilar contrato** (`scarb build`)
- [ ] **Declarar contrato** (starkli declare)
- [ ] **Deployar contrato** (starkli deploy)
- [ ] **Guardar dirección** del contrato
- [ ] **Verificar en explorer**
- [ ] **Registrar 2-3 boyas** de prueba
- [ ] **Configurar backend** con address del contrato
- [ ] **Probar endpoints** del backend
- [ ] **Conectar dashboard** con backend

### OPCIONAL PERO RECOMENDADO:

- [ ] Configurar Supabase para datos reales
- [ ] Agregar más boyas de prueba
- [ ] Crear video demo de 2-3 minutos
- [ ] Preparar slides para presentación
- [ ] Ensayar pitch 3 veces

## 🎯 TIEMPO ESTIMADO

**Setup inicial (Scarb + Wallet):** 30 min  
**Faucet:** 15 min (puede tardar más)  
**Deploy:** 30 min  
**Testing:** 30 min  
**Configuración total:** 30 min  

**Total:** ~2.5 horas

## 📚 ARCHIVOS IMPORTANTES

- `contracts/buoy-contract.cairo` - Contrato a deployar
- `DEPLOY-STARKNET.md` - Instrucciones detalladas
- `backend/src/routes/data.ts` - Endpoints ya configurados
- `frontend/dashboard.html` - Dashboard funcionando

## 🚨 SI TIENES PROBLEMAS

### Scarb no instala
```bash
# Windows: Usar PowerShell admin
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://docs.swmansion.com/scarb/install.sh'))
```

### No tienes ETH
- Esperar a que faucet responda (puede tardar horas)
- O pedir ETH a alguien del hackathon

### Error al compilar
- Verificar versión de Scarb
- Verificar sintaxis Cairo 2.0
- Revisar errores en terminal

### Contrato no deploya
- Verificar que tienes ETH
- Verificar que la red es correcta (sepolia)
- Verificar que la cuenta existe

## ✅ RESULTADO ESPERADO

Después de completar los pasos:

1. **Contrato desplegado** en Starknet Sepolia
2. **Dirección del contrato:** `0x...` (guardar)
3. **Explorer:** URL para mostrar durante pitch
4. **2-3 boyas registradas** on-chain
5. **Backend conectado** con contrato
6. **Dashboard actualizado** con datos reales

## 🎬 PARA EL DEMO

**Mostrarás:**
- "Aquí está el contrato en StarkScan: [URL]"
- "Registré 8 boyas como NFTs on-chain"
- "Los datos se guardan en blockchain y Supabase"
- "El dashboard muestra datos en tiempo real"

## 🚀 COMANDOS RÁPIDOS DE DEPLOY

Si ya tienes todo instalado:

```bash
# 1. Compilar
cd contracts && scarb build

# 2. Declarar y deployar (todo en uno)
starkli declare-and-deploy target/dev/buoy_registry.sierra.json \
  --account ocean-sense \
  --rpc https://starknet-sepolia.public.blastapi.io

# 3. Guardar dirección
CONTRACT=$(starkli deploy-output)
echo "Contract: $CONTRACT"

# 4. Registrar primera boya
starkli invoke $CONTRACT register_buoy \
  --calldata "BUOY_001" "-1205000" "-7715000" \
  --account ocean-sense

# 5. Verificar
starkli call $CONTRACT get_total_buoys
```

## 📞 SOPORTE

Si tienes problemas:
1. Verificar logs en terminal
2. Revisar `DEPLOY-STARKNET.md` para más detalles
3. Consultar documentación de Starknet: https://docs.starknet.io
4. Preguntar en Discord de Starknet o el hackathon

