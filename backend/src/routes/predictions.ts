import { Router, Request, Response } from 'express';
import axios from 'axios';

const router = Router();
const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:5000';

/**
 * GET /api/predictions/fishing-zones
 * Predicciones ML de mejores zonas de pesca
 */
router.get('/fishing-zones', async (req: Request, res: Response) => {
  try {
    // Por ahora, devolvemos datos simulados
    // En producción, llamaría al servicio ML
    const mockPredictions = [
      {
        latitude: -12.0564,
        longitude: -77.1181,
        probability: 0.85,
        temperature: 19.5,
        conditions: 'Óptimas',
        recommendation: 'Zona altamente recomendada para pesca'
      },
      {
        latitude: -12.0612,
        longitude: -77.1254,
        probability: 0.72,
        temperature: 20.1,
        conditions: 'Buenas',
        recommendation: 'Buena probabilidad de captura'
      },
      {
        latitude: -12.0523,
        longitude: -77.1123,
        probability: 0.68,
        temperature: 21.2,
        conditions: 'Buenas',
        recommendation: 'Condiciones favorables'
      }
    ];

    res.json({
      predictions: mockPredictions,
      generated_at: new Date().toISOString(),
      note: 'Using mock data - ML service integration pending'
    });

  } catch (error: any) {
    console.error('Error getting predictions:', error);
    res.status(500).json({ error: 'Prediction service unavailable' });
  }
});

/**
 * GET /api/predictions/anomalies
 * Detección de anomalías en tiempo real
 */
router.get('/anomalies', async (req: Request, res: Response) => {
  try {
    // Datos simulados de anomalías
    const mockAnomalies = [
      {
        buoy_id: 'BUOY_001',
        location: { lat: -12.0564, lon: -77.1181 },
        type: 'TEMPERATURA_ANOMALA',
        severity: 65,
        message: 'Temperatura 23.2°C está 2.8σ fuera de lo normal (19.5°C)',
        timestamp: new Date().toISOString(),
        recommended_actions: [
          'Verificar con boyas adyacentes',
          'Evaluar posible inicio de El Niño',
          'Actualizar modelos predictivos'
        ]
      }
    ];

    res.json({
      anomalies: mockAnomalies,
      total: mockAnomalies.length,
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('Error detecting anomalies:', error);
    res.status(500).json({ error: 'Anomaly detection unavailable' });
  }
});

export default router;

