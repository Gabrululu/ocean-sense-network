import { Router, Request, Response } from 'express';
import { prisma } from '../index';

const router = Router();

/**
 * GET /api/analytics/el-nino-forecast
 * Predicción de El Niño basada en datos históricos
 */
router.get('/el-nino-forecast', async (req: Request, res: Response) => {
  try {
    // Análisis de tendencias de temperatura últimos 6 meses
    const sixMonthsAgo = new Date(Date.now() - 6 * 30 * 24 * 60 * 60 * 1000);

    const tempTrend = await prisma.$queryRaw<any[]>`
      SELECT 
        DATE_TRUNC('week', timestamp) as week,
        AVG(temperature) as avg_temp,
        COUNT(*) as data_points
      FROM "SensorReading"
      WHERE timestamp > ${sixMonthsAgo}::timestamp
        AND temperature IS NOT NULL
      GROUP BY week
      ORDER BY week
    `;

    // Calcular probabilidad de El Niño (simulado)
    const recentTemps = tempTrend.map((t: any) => t.avg_temp as number);
    const avgTemp = recentTemps.reduce((a: number, b: number) => a + b, 0) / recentTemps.length;
    
    // El Niño se caracteriza por temperaturas más altas de lo normal
    const baseline = 19.5; // Temperatura normal para el Callao
    const anomaly = avgTemp - baseline;
    
    let probability = 0;
    let severity = 'Normal';
    
    if (anomaly > 1.5) {
      probability = 0.85;
      severity = 'El Niño Fuerte';
    } else if (anomaly > 1.0) {
      probability = 0.65;
      severity = 'El Niño Moderado';
    } else if (anomaly > 0.5) {
      probability = 0.45;
      severity = 'Condiciones Cálidas';
    } else if (anomaly < -1.0) {
      probability = 0.15;
      severity = 'La Niña';
    }

    res.json({
      probability,
      severity,
      anomaly_celsius: parseFloat(anomaly.toFixed(2)),
      average_temperature: parseFloat(avgTemp.toFixed(2)),
      baseline_temperature: baseline,
      trend: tempTrend,
      forecast_date: new Date().toISOString(),
      recommendation: probability > 0.5 
        ? 'Condiciones similares a El Niño detectadas. Alertar a cooperativas pesqueras.'
        : 'Condiciones normales para la época.'
    });

  } catch (error: any) {
    console.error('Error forecasting El Niño:', error);
    res.status(500).json({ error: 'Forecast unavailable' });
  }
});

/**
 * GET /api/analytics/stats
 * Estadísticas generales del sistema
 */
router.get('/stats', async (req: Request, res: Response) => {
  try {
    const totalBuoys = await prisma.buoy.count();
    const totalReadings = await prisma.sensorReading.count();
    const activeBuoys = await prisma.$queryRaw<any[]>`
      SELECT COUNT(DISTINCT buoy_id) as count
      FROM "SensorReading"
      WHERE timestamp > NOW() - INTERVAL '24 hours'
    `;

    const recentReadings = await prisma.sensorReading.findMany({
      where: {
        timestamp: {
          gte: new Date(Date.now() - 24 * 60 * 60 * 1000)
        }
      },
      select: {
        temperature: true,
        ph: true,
        salinity: true
      }
    });

    const filteredTemp = recentReadings.filter((r: any) => r.temperature);
    const avgTemp = filteredTemp.length > 0
      ? filteredTemp.reduce((sum: number, r: any) => sum + (r.temperature || 0), 0) / filteredTemp.length
      : 0;

    const filteredPh = recentReadings.filter((r: any) => r.ph);
    const avgPh = filteredPh.length > 0
      ? filteredPh.reduce((sum: number, r: any) => sum + (r.ph || 0), 0) / filteredPh.length
      : 0;

    res.json({
      total_buoys: totalBuoys,
      active_buoys: activeBuoys[0]?.count || 0,
      total_readings: totalReadings,
      average_temperature: parseFloat(avgTemp.toFixed(2)) || null,
      average_ph: parseFloat(avgPh.toFixed(2)) || null,
      last_updated: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('Error getting stats:', error);
    res.status(500).json({ error: 'Failed to get stats' });
  }
});

export default router;

