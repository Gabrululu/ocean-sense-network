import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';

// Import routes
import dataRoutes from './routes/data';
import predictionRoutes from './routes/predictions';
import marketplaceRoutes from './routes/marketplace';
import buoyRoutes from './routes/buoys';
import analyticsRoutes from './routes/analytics';

dotenv.config();

const app = express();
const prisma = new PrismaClient();

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    service: 'Ocean-Sense Network API'
  });
});

// Routes
app.use('/api/data', dataRoutes);
app.use('/api/predictions', predictionRoutes);
app.use('/api/marketplace', marketplaceRoutes);
app.use('/api/buoys', buoyRoutes);
app.use('/api/analytics', analyticsRoutes);

// Error handling middleware
app.use((err: any, req: Request, res: Response, next: any) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error'
  });
});

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`🌊 Ocean-Sense Network API running on port ${PORT}`);
});

export { prisma };

