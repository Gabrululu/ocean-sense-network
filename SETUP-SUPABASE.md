# 📦 Setup de Supabase

## 1. Crear Proyecto en Supabase

1. Ve a https://supabase.com
2. Crea cuenta (gratis)
3. "New Project"
4. Nombre: `ocean-sense-network`
5. Región: `South America (Sao Paulo)`
6. Database password: [guarda esto]
7. Espera ~2 minutos a que cree el proyecto

## 2. Obtener Credenciales

En tu proyecto de Supabase:
1. Settings → API
2. Copiar:
   - `Project URL` → `https://xxxxx.supabase.co`
   - `anon/public` key

## 3. Crear Tablas

Ve a SQL Editor en Supabase y ejecuta:

```sql
-- Tabla de lecturas de sensores
CREATE TABLE sensor_readings (
  id BIGSERIAL PRIMARY KEY,
  buoy_id TEXT NOT NULL,
  temperature FLOAT,
  ph FLOAT,
  salinity FLOAT,
  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL,
  battery_level INT,
  hydrocarbon_ppm FLOAT DEFAULT 0,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_buoy_id ON sensor_readings(buoy_id);
CREATE INDEX idx_timestamp ON sensor_readings(timestamp);

-- Tabla de boyas
CREATE TABLE buoys (
  id BIGSERIAL PRIMARY KEY,
  buoy_id TEXT UNIQUE NOT NULL,
  owner_address TEXT NOT NULL,
  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL,
  metadata_hash TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar Row Level Security (RLS)
ALTER TABLE sensor_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE buoys ENABLE ROW LEVEL SECURITY;

-- Política: Permitir lectura pública
CREATE POLICY "Allow public read access"
ON sensor_readings FOR SELECT
USING (true);

CREATE POLICY "Allow public read access"
ON buoys FOR SELECT
USING (true);

-- Política: Permitir inserción pública (para boyas)
CREATE POLICY "Allow public insert"
ON sensor_readings FOR INSERT
WITH CHECK (true);

-- Política: Permitir actualización pública
CREATE POLICY "Allow public update"
ON sensor_readings FOR UPDATE
USING (true);
```

## 4. Configurar Backend

Crear `backend/.env`:

```env
# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Backend
PORT=3001
NODE_ENV=development

# Starknet
STARKNET_NETWORK=sepolia
STARKNET_CONTRACT_ADDRESS=0x... (después del deploy)
```

## 5. Agregar Dependencia

```bash
cd backend
npm install @supabase/supabase-js
```

## 6. Verificar Conexión

```bash
# Ejecutar backend
npm run dev

# En otra terminal, probar:
curl http://localhost:3001/api/data/realtime

# Debería devolver datos (mock por ahora)
```

## 7. Insertar Datos de Prueba

En Supabase SQL Editor:

```sql
-- Insertar boyas de prueba
INSERT INTO buoys (buoy_id, owner_address, latitude, longitude, metadata_hash)
VALUES
  ('BUOY_CALLAO_NORTE', '0x1234...', -12.05, -77.15, 'QmHash1'),
  ('BUOY_ANCON', '0x1234...', -11.76, -77.18, 'QmHash2'),
  ('BUOY_HUACHO', '0x1234...', -11.11, -77.61, 'QmHash3');

-- Insertar lecturas de prueba
INSERT INTO sensor_readings (buoy_id, temperature, ph, salinity, latitude, longitude, battery_level)
VALUES
  ('BUOY_CALLAO_NORTE', 19.2, 7.2, 33.1, -12.05, -77.15, 85),
  ('BUOY_ANCON', 18.8, 8.1, 35.2, -11.76, -77.18, 92),
  ('BUOY_HUACHO', 18.3, 8.0, 35.0, -11.11, -77.61, 78);
```

## 8. Verificar en Supabase

1. Ve a Table Editor
2. Deberías ver:
   - Tabla `sensor_readings` con 3 filas
   - Tabla `buoys` con 3 filas

## Para el Demo

**Durante el pitch puedes mostrar:**
- "Aquí está nuestra base de datos en Supabase"
- "En tiempo real se están guardando lecturas"
- "Los datos son públicos y verificables"

## Actualizar Backend para Usar Supabase

Editar `backend/src/routes/data.ts`:

```typescript
// Ya está configurado para usar Supabase
// Solo necesitas:
// 1. Configurar .env con credenciales
// 2. Ejecutar npm install @supabase/supabase-js
// 3. Reiniciar backend
```

## Troubleshooting

**Error: "Invalid API key"**
- Verificar que copiaste la clave correcta
- Asegúrate de usar la `anon/public` key (no la `service_role`)

**Error: "table does not exist"**
- Verificar que ejecutaste el SQL de creación de tablas
- Revisar que estás en el proyecto correcto de Supabase

**Error: "row-level security policy"**
- Revisar las políticas RLS en Supabase
- Temporalmente desabilitar RLS si es para testing

