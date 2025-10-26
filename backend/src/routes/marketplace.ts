import { Router, Request, Response } from 'express';
import { prisma } from '../index';

const router = Router();

/**
 * GET /api/marketplace/packages
 * Lista todos los paquetes de datos disponibles
 */
router.get('/packages', async (req: Request, res: Response) => {
  try {
    const packages = await prisma.dataPackage.findMany({
      where: { isActive: true },
      orderBy: { createdAt: 'desc' }
    });

    res.json(packages);

  } catch (error: any) {
    console.error('Error fetching packages:', error);
    res.status(500).json({ error: 'Failed to fetch packages' });
  }
});

/**
 * GET /api/marketplace/packages/:packageId
 * Obtener detalles de un paquete específico
 */
router.get('/packages/:packageId', async (req: Request, res: Response) => {
  try {
    const { packageId } = req.params;
    
    const dataPackage = await prisma.dataPackage.findUnique({
      where: { packageId: packageId }
    });

    if (!dataPackage) {
      return res.status(404).json({ error: 'Package not found' });
    }

    res.json(dataPackage);

  } catch (error: any) {
    console.error('Error fetching package:', error);
    res.status(500).json({ error: 'Failed to fetch package' });
  }
});

/**
 * POST /api/marketplace/packages/create
 * Crear nuevo paquete de datos para vender
 */
router.post('/packages/create', async (req: Request, res: Response) => {
  try {
    const {
      time_start,
      time_end,
      area,
      price,
      data_hash
    } = req.body;

    if (!time_start || !time_end || !area || !price) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const dataPackage = await prisma.dataPackage.create({
      data: {
        packageId: `PKG_${Date.now()}`,
        sellerAddress: '0x0', // TODO: Get from auth
        price: BigInt(price),
        dataHash: data_hash || 'mock_hash',
        timeRangeStart: new Date(time_start),
        timeRangeEnd: new Date(time_end),
        areaCode: area,
        isActive: true
      }
    });

    res.json({
      success: true,
      package: dataPackage
    });

  } catch (error: any) {
    console.error('Error creating package:', error);
    res.status(500).json({ error: 'Failed to create package' });
  }
});

export default router;

