interface SensorReading {
  temperature: number | null;
  ph: number | null;
  salinity: number | null;
  latitude: number;
  longitude: number;
  batteryLevel: number | null;
}

export function calculateDataQuality(reading: SensorReading): number {
  let score = 100;

  // Penalizar si faltan datos
  if (reading.temperature === null) score -= 20;
  if (reading.ph === null) score -= 20;
  if (!reading.latitude || !reading.longitude) score -= 30;

  // Penalizar valores fuera de rango esperado para el océano
  if (reading.temperature !== null) {
    if (reading.temperature < 10 || reading.temperature > 30) score -= 10;
    if (reading.temperature < 15 || reading.temperature > 28) score -= 5; // Rango más típico
  }

  if (reading.ph !== null) {
    if (reading.ph < 6 || reading.ph > 9) score -= 10;
    if (reading.ph < 7.5 || reading.ph > 8.5) score -= 5; // Rango óptimo para océano
  }

  if (reading.salinity !== null) {
    // Salinidad típica del océano: 30-40 ppt
    if (reading.salinity < 25 || reading.salinity > 45) score -= 10;
    if (reading.salinity < 30 || reading.salinity > 40) score -= 5;
  }

  // Penalizar si la batería está baja
  if (reading.batteryLevel !== null && reading.batteryLevel < 20) {
    score -= 5;
  }

  return Math.max(score, 0);
}

export function validateSensorReading(data: any): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  // Validaciones básicas
  if (!data.latitude || isNaN(data.latitude)) {
    errors.push('Latitude is required and must be a number');
  }
  if (!data.longitude || isNaN(data.longitude)) {
    errors.push('Longitude is required and must be a number');
  }

  // Rango de latitud/longitud para el Callao, Perú
  if (data.latitude && (data.latitude < -13 || data.latitude > -11)) {
    errors.push('Latitude out of range for Peruvian coast');
  }
  if (data.longitude && (data.longitude < -78 || data.longitude > -76)) {
    errors.push('Longitude out of range for Peruvian coast');
  }

  // Validar temperatura
  if (data.temperature && (data.temperature < 5 || data.temperature > 35)) {
    errors.push('Temperature out of expected ocean range');
  }

  // Validar pH
  if (data.ph && (data.ph < 6 || data.ph > 9)) {
    errors.push('pH out of expected ocean range');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

