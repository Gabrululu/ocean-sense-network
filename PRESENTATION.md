# 🌊 Ocean-Sense Network - Presentación Hackathon

## El Problema

### Situación Actual

- **3,080 km de costa peruana** con datos limitados sobre parámetros oceánicos
- **Fenómeno El Niño** afecta la pesca artesanal (40% del empleo pesquero)
- **Derrames petroleros** frecuentes sin detección temprana (Repsol 2022)
- Pérdidas económicas de **$3 billones** por El Niño 2023-2024

### Impacto Social

- **40%** del empleo pesquero es artesanal
- Pescadores sin herramientas modernas de predicción
- Sin sistema de alertas tempranas de contaminación
- Datos científicos limitados para investigación

## Nuestra Solución

### Ocean-Sense Network

**DePIN para Monitoreo Oceánico Descentralizado**

- Red de **boyas IoT** de bajo costo (~$200-500 c/u)
- Desplegadas por **pescadores artesanales**
- Cada boya mide: temperatura, pH, salinidad, hidrocarburos
- **IA** procesa datos para:
  - Predecir zonas de pesca óptimas
  - Alertar contaminación temprana
  - Predecir El Niño/La Niña

### ¿Por Qué DePIN?

✅ **Incentivos Económicos**: Pescadores ganan tokens por mantener boyas  
✅ **Datos Descentralizados**: No hay un solo punto de falla  
✅ **Transparencia**: Todos los datos en blockchain (Starknet)  
✅ **Mercado de Datos**: Venta de datos agregados a empresas/investigación  
✅ **Verificable**: Resultados medibles on-chain  

## Arquitectura Técnica

### 5 Capas Principales

1. **Hardware (DePIN)**
   - ESP32 + sensores marinos
   - Comunicación WiFi/LoRa
   - Energía solar

2. **Backend API**
   - Node.js + Express
   - PostgreSQL + TimescaleDB
   - Redis para cache

3. **Blockchain (Starknet)**
   - Smart contracts Cairo
   - Registry de boyas (NFTs)
   - Sistema de recompensas
   - Marketplace de datos

4. **Inteligencia Artificial**
   - Python + scikit-learn
   - Predicción de zonas de pesca
   - Detección de anomalías

5. **Frontend**
   - Dashboard web interactivo
   - Mapa en tiempo real
   - Visualización de predicciones

## Demo MVP

### 1. Simulador de Boyas

```bash
cd hardware/simulator
npm install
node simulate-buoys.js
```

**Simula:**
- 3 boyas en el Callao, Perú
- Datos cada 5 minutos
- Temperatura, pH, salinidad, GPS
- Nivel de batería

### 2. API Endpoints

- `GET /api/data/realtime` - Datos en vivo
- `GET /api/predictions/fishing-zones` - Predicciones
- `GET /api/analytics/el-nino-forecast` - Pronóstico El Niño
- `GET /api/marketplace/packages` - Marketplace

### 3. Dashboard Web

- Mapa interactivo con boyas
- Predicciones de zonas de pesca
- Sistema de alertas
- Estadísticas en tiempo real

## Modelo de Negocio

### Revenue Streams

1. **Venta de Datos Agregados**
   - Empresas pesqueras
   - Navieras
   - Instituciones de investigación
   - Gobierno

2. **Seguro Paramétrico**
   - Pago automático si condiciones malas
   - Protección para pescadores artesanales

3. **Suscripciones Premium**
   - Acceso a datos históricos completos
   - Predicciones avanzadas
   - API premium

### Tokenomics

- **Tokens de Rewards**: Por mantener boyas operativas
- **Tokens de Staking**: Para registrar nuevas boyas
- **Revenue Sharing**: Operadores reciben % de venta de datos

## Impacto Esperado

### Fase 1 (6 meses)
- 20 boyas en Callao
- 100 pescadores beneficiados
- Predicciones con 70%+ precisión

### Fase 2 (1 año)
- 100 boyas en Lima
- 1,000 pescadores
- Integración con cooperativas
- Seguro paramétrico funcionando

### Fase 3 (2 años)
- 500 boyas en toda la costa
- Predicción El Niño/La Niña
- Modelo nacional de referencia

## Diferenciación vs Competencia

✅ **DePIN Real**: Hardware físico con incentivos on-chain  
✅ **IA Aplicada**: Predicciones verificables públicamente  
✅ **Impacto Social Medible**: Alertas y prevención de pérdidas  
✅ **Múltiples Revenue Streams**: Datos, seguros, suscripciones  
✅ **Escalable**: Desde 10 hasta 10,000 boyas  

## Próximos Pasos

1. **Demo en Hackathon**: Mostrar MVP funcional
2. **Pilot en Callao**: 10 boyas reales
3. **Token Launch**: Rewards y staking system
4. **Partnerships**: Cooperativas pesqueras
5. **Scale**: 100+ boyas en 6 meses

## Stack Tecnológico

- **Blockchain**: Starknet (Cairo)
- **Backend**: Node.js, Express, TypeScript
- **DB**: PostgreSQL + TimescaleDB
- **IA/ML**: Python, scikit-learn, TensorFlow
- **Frontend**: React, Leaflet
- **Hardware**: ESP32, sensores marinos

## Equipo

**Desarrollado para EthLima Hackathon 2024**

### Tecnologías Utilizadas

- DePIN (Decentralized Physical Infrastructure)
- Web3 + Blockchain (Starknet)
- IoT (ESP32)
- IA/ML (Python)
- Full Stack (Node.js + React)

## Contacto

- **GitHub**: [repository url]
- **Demo**: http://localhost:3000
- **API**: http://localhost:3001
- **Docs**: Ve `README.md` y `ARCHITECTURE.md`

---

## 🎯 Pitch Elevator (30 segundos)

> "Ocean-Sense Network es una red DePIN que monitorea en tiempo real los 3,080 km de costa peruana usando boyas IoT descentralizadas. Pescadores ganan tokens por mantener boyas, mientras nuestra IA predice zonas óptimas de pesca y detecta contaminación temprana. Revenue: venta de datos, seguros paramétricos y suscripciones. Impacto: prevenir pérdidas de $3B por El Niño."

---

**🌊 Protegiendo el océano peruano, una boya a la vez**

