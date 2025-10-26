/**
 * Simulador de Boyas IoT para Ocean-Sense Network
 * Simula envío de datos de sensores marinos en tiempo real
 */

const axios = require('axios');
const API_URL = 'http://localhost:3001/api/data/ingest';

// Boyas simuladas con ubicaciones en el Callao, Perú
const buoys = [
  {
    id: 'BUOY_001',
    name: 'Boya Norte Callao',
    baseLat: -12.0564,
    baseLon: -77.1181,
    drift: 0.001
  },
  {
    id: 'BUOY_002',
    name: 'Boya Sur Callao',
    baseLat: -12.0612,
    baseLon: -77.1254,
    drift: 0.0012
  },
  {
    id: 'BUOY_003',
    name: 'Boya Centro',
    baseLat: -12.0523,
    baseLon: -77.1123,
    drift: 0.0008
  }
];

// Parámetros oceánicos base (típicos del Callao)
const baselineParams = {
  temperature: { base: 19.5, range: 2.0 },
  ph: { base: 8.0, range: 0.3 },
  salinity: { base: 35.0, range: 2.0 },
  battery: { base: 85, range: 10 }
};

// Función para generar datos realistas con variación aleatoria
function generateSensorData(buoy) {
  const now = Date.now();
  
  // Simular deriva de la boya
  const lat = buoy.baseLat + Math.sin(now / 3600000) * buoy.drift;
  const lon = buoy.baseLon + Math.cos(now / 3600000) * buoy.drift;
  
  // Generar temperaturas con variación diurna
  const hourOfDay = new Date().getHours();
  const tempVariation = Math.sin((hourOfDay - 6) * Math.PI / 12) * 1.5;
  
  const temperature = baselineParams.temperature.base + tempVariation + 
    (Math.random() - 0.5) * baselineParams.temperature.range;
  
  // pH con variación mínima
  const ph = baselineParams.ph.base + (Math.random() - 0.5) * baselineParams.ph.range;
  
  // Salinidad relativamente estable
  const salinity = baselineParams.salinity.base + (Math.random() - 0.5) * baselineParams.salinity.range;
  
  // Batería disminuye gradualmente
  const battery = Math.max(50, baselineParams.battery.base - Math.random() * 10);
  
  return {
    buoy_id: buoy.id,
    temperature: parseFloat(temperature.toFixed(2)),
    ph: parseFloat(ph.toFixed(2)),
    salinity: parseFloat(salinity.toFixed(2)),
    latitude: parseFloat(lat.toFixed(6)),
    longitude: parseFloat(lon.toFixed(6)),
    battery: Math.round(battery),
    timestamp: now
  };
}

// Función para enviar datos de una boya
async function sendBuoyData(buoy) {
  const data = generateSensorData(buoy);
  
  try {
    const response = await axios.post(API_URL, data);
    console.log(`✅ ${buoy.name}:`, {
      temp: data.temperature,
      ph: data.ph,
      battery: data.battery
    });
    
    // Ocasionalmente simular detección de derrame (5% probabilidad)
    if (Math.random() < 0.05) {
      const alertData = {
        ...data,
        hydrocarbon_ppm: 8.5
      };
      await axios.post(API_URL, alertData);
      console.log(`🚨 ALERTA: Posible derrame detectado en ${buoy.name}`);
    }
    
  } catch (error) {
    console.error(`❌ Error enviando datos de ${buoy.name}:`, error.message);
  }
}

// Función principal para enviar datos de todas las boyas
async function simulateBuoys() {
  console.log('🌊 Ocean-Sense Network - Simulador de Boyas');
  console.log('Enviando datos de', buoys.length, 'boyas...\n');
  
  // Enviar datos de todas las boyas simultáneamente
  const promises = buoys.map(buoy => sendBuoyData(buoy));
  
  try {
    await Promise.all(promises);
  } catch (error) {
    console.error('Error en simulación:', error);
  }
}

// Ejecutar cada 5 minutos (300 segundos)
async function runContinuous() {
  console.log('Iniciando simulación continua...\n');
  
  // Ejecutar inmediatamente
  await simulateBuoys();
  
  // Ejecutar cada 5 minutos
  setInterval(async () => {
    await simulateBuoys();
  }, 5 * 60 * 1000);
}

// Verificar si se debe ejecutar en modo continuo
const CONTINUOUS = process.argv.includes('--continuous') || process.argv.includes('-c');

if (CONTINUOUS) {
  console.log('Modo continuo activado (cada 5 minutos)\n');
  runContinuous();
} else {
  // Ejecutar solo una vez
  simulateBuoys().then(() => {
    console.log('\n✅ Simulación completada');
    console.log('Para modo continuo, ejecuta: node simulate-buoys.js --continuous');
    process.exit(0);
  });
}

