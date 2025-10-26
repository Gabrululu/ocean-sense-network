/**
 * Script para poblar la base de datos con datos de ejemplo
 */

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌊 Poblando base de datos de Ocean-Sense Network...');

  // Crear boyas de ejemplo
  const buoys = [
    {
      buoyId: 'BUOY_001',
      ownerAddress: '0x1234567890abcdef1234567890abcdef12345678',
      metadataHash: 'QmExampleHash1',
      locationHash: 'CALLAO_NORTH',
      latitude: -12.0564,
      longitude: -77.1181
    },
    {
      buoyId: 'BUOY_002',
      ownerAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
      metadataHash: 'QmExampleHash2',
      locationHash: 'CALLAO_SOUTH',
      latitude: -12.0612,
      longitude: -77.1254
    },
    {
      buoyId: 'BUOY_003',
      ownerAddress: '0x9876543210fedcba9876543210fedcba98765432',
      metadataHash: 'QmExampleHash3',
      locationHash: 'CALLAO_CENTRO',
      latitude: -12.0523,
      longitude: -77.1123
    }
  ];

  for (const buoyData of buoys) {
    const buoy = await prisma.buoy.upsert({
      where: { buoyId: buoyData.buoyId },
      update: {},
      create: buoyData
    });
    console.log(`✅ Boya creada: ${buoy.buoyId}`);
  }

  console.log('✅ Base de datos poblada correctamente');
}

main()
  .catch((e) => {
    console.error('❌ Error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

