# Ocean-Sense Network 🌊

**DePIN para Monitoreo Oceánico Descentralizado del Litoral Peruano**

## 🎯 El Problema

Perú tiene **3,080 km de costa** sin datos en tiempo real sobre:
- Temperatura y corrientes oceánicas
- Contaminación y derrames petroleros
- Condiciones para pesca artesanal

**El Niño 2023-2024** causó **$3B en pérdidas**, afectando principalmente a 40,000 pescadores artesanales que operan sin información confiable.

## 💡 Nuestra Solución

**Ocean-Sense Network** es una red DePIN de **boyas IoT** operadas por pescadores artesanales que:

✅ Miden parámetros oceánicos en tiempo real  
✅ Detectan contaminación y derrames automáticamente  
✅ Predicen zonas óptimas de pesca con **IA**  
✅ Compensan a operadores con **tokens (Starknet)**  

## 🏗️ Arquitectura

```
┌──────────────┐
│  Boyas IoT   │ (ESP32 + Sensores ~$210)
│  (Hardware)  │
└──────┬───────┘
       │
       ↓
┌────────────────────┐
│  Backend API       │ (Node.js + Supabase)
│  + Validación      │
└────────┬───────────┘
         │
         ↓
┌────────────────────┐
│  Smart Contracts   │ (Starknet Sepolia)
│  + NFTs            │
│  + Rewards         │
└────────┬───────────┘
         │
         ↓
┌────────────────────┐
│  IA + ML           │ (Python)
│  + Predicciones    │
└────────┬───────────┘
         │
         ↓
┌────────────────────┐
│  Dashboard Web     │ (HTML + Leaflet)
│  + Mapas           │
└────────────────────┘
```

## 🚀 Quick Start

### Ver Dashboard

```bash
# Solo abre el HTML
cd frontend
open dashboard.html
# o en Windows:
start dashboard.html
```

Ya funciona con datos mock. ✅

### Deploy Completo

Para deployar en Starknet, sigue: **[DEPLOY-STEP-BY-STEP.md](DEPLOY-STEP-BY-STEP.md)**

Resumen rápido:

```bash
# 1. Instalar herramientas
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh

# 2. Crear cuenta
starkli account new --account ocean-sense

# 3. Obtener ETH de faucet
# https://faucet.starknet.io/

# 4. Deploy contrato
cd contracts
scarb build
starkli declare-and-deploy target/dev/buoy_registry.sierra.json --account ocean-sense

# 5. Ejecutar backend
cd ../backend
npm install
npm run dev

# 6. Abrir dashboard
cd ../frontend
open dashboard.html
```

## 📁 Estructura del Proyecto

```
ocean-sense-network/
├── frontend/
│   ├── dashboard.html       ← Ábrelo en navegador
│   └── dashboard-data.js
├── backend/
│   ├── src/
│   │   ├── routes/
│   │   └── config/supabase.ts
│   └── .env                 ← Configurar
├── contracts/
│   └── buoy-contract.cairo  ← Deploy en Starknet
├── ml-service/
│   ├── app.py              ← Servicio ML
│   └── models/
├── hardware/
│   └── simulator/
│       └── simulate-buoys.js
└── docs/
    ├── DEPLOY-STEP-BY-STEP.md  ← GUÍA COMPLETA
    ├── SETUP-SUPABASE.md
    └── DEPLOY-STARKNET.md
```

## 🔗 Tecnología

- **Blockchain:** Starknet (Cairo 2.0)
- **Backend:** Node.js, Express, Supabase
- **IA/ML:** Python, Flask, scikit-learn
- **Frontend:** HTML, CSS, JavaScript, Leaflet
- **Hardware:** ESP32, sensores marinos

## 📊 Stack Tecnológico

- **Blockchain:** Starknet + Cairo
- **Database:** Supabase (PostgreSQL)
- **IA/ML:** Python + scikit-learn
- **Frontend:** HTML/CSS/JS + Leaflet
- **Hardware:** ESP32

## 🎯 Modelo Económico

| Stakeholder | Rol | Incentivo |
|-------------|-----|-----------|
| **Pescadores** | Operan boyas | 10-50 tokens/día |
| **Empresas Pesqueras** | Compran datos | $500-2000/mes |
| **Navieras** | Optimización | $1000+/mes |
| **Gobierno** | Monitoreo | Datos públicos |

## 📈 Impacto

- 🎯 **40,000 pescadores** con mejor información
- 📊 **+30% eficiencia** en captura
- ⚠️ **Detección temprana** de derrames (< 2 horas)
- 🌍 **Datos abiertos** para ciencia del clima

## 🎓 Desarrollo

Proyecto desarrollado para **EthLima Hackathon 2024**

## 📄 Licencia

MIT License

---

## 🚨 Lo Que Falta Hacer

Ver **[DEPLOY-STEP-BY-STEP.md](DEPLOY-STEP-BY-STEP.md)** para lista completa.

Resumen:
1. Instalar Scarb (compilador Cairo)
2. Crear cuenta Starknet
3. Obtener ETH de faucet
4. Deploy contrato a Sepolia
5. Configurar backend
6. Conectar dashboard con backend

**Tiempo estimado:** 2-3 horas

---

*"Datos del océano, en manos de quien más lo conoce: los pescadores"* 🌊⚓
