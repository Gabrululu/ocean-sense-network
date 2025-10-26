import { Router, Request, Response } from 'express';
import { prisma } from '../index';

const router = Router();

/**
 * GET /api/buoys
 * Lista todas las boyas registradas
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const buoys = await prisma.buoy.findMany({
      include: {
        _count: {
          select: { readings: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json(buoys);

  } catch (error: any) {
    console.error('Error fetching buoys:', error);
    res.status(500).json({ error: 'Failed to fetch buoys' });
  }
});

/**
 * GET /api/buoys/:buoyId
 * Obtener información detallada de una boya
 */
router.get('/:buoyId', async (req: Request, res: Response) => {
  try {
    const { buoyId } = req.params;

    const buoy = await prisma.buoy.findUnique({
      where: { id: buoyId },
      include: {
        readings: {
          take: 10,
          orderBy: { timestamp: 'desc' }
        }
      }
    });

    if (!buoy) {
      return res.status(404).json({ error: 'Buoy not found' });
    }

    res.json(buoy);

  } catch (error: any) {
    console.error('Error fetching buoy:', error);
    res.status(500).json({ error: 'Failed to fetch buoy' });
  }
});

/**
 * POST /api/buoys/register
 * Registrar nueva boya
 */
router.post('/register', async (req: Request, res: Response) => {
  try {
    const {
      buoy_id,
      owner_address,
      metadata_hash,
      location_hash,
      latitude,
      longitude
    } = req.body;

    if (!buoy_id || !owner_address || !metadata_hash) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const buoy = await prisma.buoy.create({
      data: {
        buoyId: buoy_id,
        ownerAddress: owner_address,
        metadataHash: metadata_hash,
        locationHash: location_hash || '',
        latitude: latitude ? parseFloat(latitude) : null,
        longitude: longitude ? parseFloat(longitude) : null
      }
    });

    res.json({
      success: true,
      buoy
    });

  } catch (error: any) {
    console.error('Error registering buoy:', error);
    res.status(500).json({ error: 'Failed to register buoy' });
  }
});

export default router;

