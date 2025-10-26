# Arquitectura - Ocean-Sense Network

## Visión General

Ocean-Sense Network es una red DePIN (Decentralized Physical Infrastructure Network) que monitorea las condiciones oceánicas del litoral peruano utilizando boyas IoT descentralizadas.

## Capas del Sistema

### 1. Capa de Hardware (DePIN)

**Componentes:**
- Boyas IoT con ESP32
- Sensores marinos:
  - Temperatura (DS18B20)
  - pH (Atlas Scientific)
  - Salinidad (TDS Meter)
  - Hidrocarburos (MQ-2)
  - GPS (NEO-6M)
- Comunicación: WiFi/LoRa
- Energía: Panel solar + batería LiPo

**Especificaciones:**
- Costo: ~$200-500 por boya
- Duración de batería: 3-5 días sin sol
- Rango LoRa: hasta 15km
- Material: HDPE resistente a UV

### 2. Capa de Agregación de Datos

**Backend API (Node.js + Express)**
- Endpoints REST para ingesta de datos
- Validación de calidad de datos
- Almacenamiento en TimescaleDB (PostgreSQL extendido)
- Cache en Redis
- Queue de mensajes para procesamiento asíncrono

**Base de Datos:**
- PostgreSQL con extensión TimescaleDB
- Tablas principales:
  - Buoys (registro de boyas)
  - SensorReading (series temporales)
  - DataPackage (paquetes de datos)
  - Alert (alertas de anomalías)
  - RewardMetrics (métricas de recompensas)

### 3. Capa Blockchain (Starknet)

**Smart Contracts:**
1. **BuoyRegistry.cairo**
   - Registro de boyas como NFTs
   - Ownership y transferencias
   - Staking para operadores

2. **RewardDistributor.cairo**
   - Cálculo de recompensas por uptime y calidad
   - Distribución de tokens ERC20
   - Oracle integration para actualizar métricas

3. **DataMarketplace.cairo**
   - Marketplace de datos agregados
   - Licencias de acceso IPFS
   - Revenue sharing

### 4. Capa de Inteligencia Artificial

**Servicios ML (Python + Flask):**
1. **Fishing Zone Predictor**
   - Predicción de zonas óptimas de pesca
   - Modelo: Random Forest / Red Neuronal
   - Input: temperatura, pH, salinidad, corrientes

2. **Ocean Anomaly Detector**
   - Detección de derrames petroleros
   - Acidificación oceánica
   - Temperaturas anómalas
   - Modelo: Isolation Forest + Z-score

**Alertas:**
- Prioridad CRITICAL (>80 severidad)
- Prioridad HIGH (50-80)
- Prioridad MEDIUM (<50)

### 5. Capa de Presentación

**Frontend (HTML + JavaScript + Leaflet)**
- Dashboard web responsivo
- Mapa interactivo con ubicación de boyas
- Visualización de predicciones en tiempo real
- Sistema de alertas

## Flujo de Datos

```
Boya IoT → HTTP/MQTT → Backend API → Validación
                                              ↓
                                    TimescaleDB (Storage)
                                              ↓
                       ┌──────────────────────┴──────────────┐
                       ↓                                     ↓
                ML Service                          Smart Contracts
              (Predicciones)                        (Starknet)
                       ↓                                     ↓
                Frontend                            IPFS Storage
            (Visualización)                      (Marketplace)
```

## Métricas de Calidad de Datos

**Score de Calidad (0-100):**
- Datos completos: +40
- Valores en rango óptimo: +30
- GPS válido: +30
- Batería adecuada: +10

**Penalizaciones:**
- Datos faltantes: -20 c/u
- Valores fuera de rango: -10 c/u
- Batería baja (<20%): -5

## Sistema de Recompensas

**Fórmula:**
```
Reward = base_rate × (uptime_factor × 0.6 + quality_factor × 0.4)

uptime_factor = (horas_activas / 168) × 100
quality_factor = score_qualidad / 100
```

**Ejemplo:**
- Boya activa 80% del tiempo (84h/168h)
- Calidad: 85/100
- Score: 80 × 0.6 + 85 × 0.4 = 48 + 34 = 82%
- Reward: 10 tokens × 0.82 = 8.2 tokens/hora

## Escalabilidad

**Fase 1 (MVP):**
- 10-20 boyas en Callao
- Predicciones básicas
- Marketplace simple

**Fase 2:**
- 100+ boyas en Lima
- IA más avanzada
- Integración con cooperativas pesqueras

**Fase 3:**
- 500+ boyas en toda la costa
- Predicción El Niño/La Niña
- Seguro paramétrico on-chain

## Seguridad

- Autenticación de boyas con signature verification
- Validación de datos en múltiples capas
- Rate limiting en API
- Encriptación en tránsito (HTTPS)
- Smart contracts audited

