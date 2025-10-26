import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

/**
 * POST /api/data/ingest
 * Endpoint para que boyas envíen datos
 */
router.post('/ingest', async (req: Request, res: Response) => {
  try {
    const {
      buoy_id,
      temperature,
      ph,
      salinity,
      latitude,
      longitude,
      battery,
      hydrocarbon_ppm
    } = req.body;

    // Validar datos requeridos
    if (!buoy_id || !latitude || !longitude) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Guardar en Supabase
    const { data, error } = await supabase
      .from('sensor_readings')
      .insert({
        buoy_id,
        temperature: temperature ? parseFloat(temperature) : null,
        ph: ph ? parseFloat(ph) : null,
        salinity: salinity ? parseFloat(salinity) : null,
        latitude: parseFloat(latitude),
        longitude: parseFloat(longitude),
        battery_level: battery ? parseInt(battery) : null,
        hydrocarbon_ppm: hydrocarbon_ppm ? parseFloat(hydrocarbon_ppm) : null,
        timestamp: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) throw error;

    res.json({
      success: true,
      reading_id: data.id,
      quality_score: 85, // Mock
      timestamp: data.timestamp
    });

  } catch (error: any) {
    console.error('Error ingesting data:', error);
    res.status(500).json({ error: 'Failed to process data' });
  }
});

/**
 * GET /api/data/realtime
 * Obtener datos en tiempo real de todas las boyas
 */
router.get('/realtime', async (req: Request, res: Response) => {
  try {
    // Por ahora, devolver datos mock
    // TODO: Conectar con Supabase cuando esté configurado
    
    const mockData = [
      { buoy_id: 'BUOY_CALLAO_NORTE', temperature: 19.2, ph: 7.2, salinity: 33.1, 
        latitude: -12.05, longitude: -77.15, battery_level: 85, hydrocarbon_ppm: 12.3 },
      { buoy_id: 'BUOY_ANCON', temperature: 18.8, ph: 8.1, salinity: 35.2,
        latitude: -11.76, longitude: -77.18, battery_level: 92, hydrocarbon_ppm: 0 },
      { buoy_id: 'BUOY_HUACHO', temperature: 18.3, ph: 8.0, salinity: 35.0,
        latitude: -11.11, longitude: -77.61, battery_level: 78, hydrocarbon_ppm: 0 },
      { buoy_id: 'BUOY_BARRANCA', temperature: 19.7, ph: 8.2, salinity: 35.4,
        latitude: -10.75, longitude: -77.76, battery_level: 88, hydrocarbon_ppm: 0 },
      { buoy_id: 'BUOY_CHIMBOTE', temperature: 17.9, ph: 8.1, salinity: 35.1,
        latitude: -9.08, longitude: -78.59, battery_level: 95, hydrocarbon_ppm: 0 },
      { buoy_id: 'BUOY_TRUJILLO', temperature: 18.4, ph: 8.0, salinity: 35.3,
        latitude: -8.11, longitude: -79.03, battery_level: 81, hydrocarbon_ppm: 0 },
      { buoy_id: 'BUOY_PACASMAYO', temperature: 19.2, ph: 8.1, salinity: 35.2,
        latitude: -7.40, longitude: -79.57, battery_level: 90, hydrocarbon_ppm: 0 },
      { buoy_id: 'BUOY_MANCORA', temperature: 22.1, ph: 8.2, salinity: 35.6,
        latitude: -4.10, longitude: -81.05, battery_level: 87, hydrocarbon_ppm: 0 },
    ];

    res.json(mockData);

  } catch (error: any) {
    console.error('Error fetching realtime data:', error);
    res.status(500).json({ error: 'Failed to fetch data' });
  }
});

/**
 * GET /api/data/historical/:buoyId
 * Obtener datos históricos de una boya específica
 */
router.get('/historical/:buoyId', async (req: Request, res: Response) => {
  try {
    const { buoyId } = req.params;
    const { hours = '24', limit = '1000' } = req.query;

    const hoursAgo = new Date(Date.now() - parseInt(hours as string) * 60 * 60 * 1000);

    const historicalData = await prisma.sensorReading.findMany({
      where: {
        buoyId: buoyId,
        timestamp: {
          gte: hoursAgo
        }
      },
      orderBy: {
        timestamp: 'desc'
      },
      take: parseInt(limit as string)
    });

    res.json(historicalData);

  } catch (error: any) {
    console.error('Error fetching historical data:', error);
    res.status(500).json({ error: 'Failed to fetch historical data' });
  }
});

export default router;

