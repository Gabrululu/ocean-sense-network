import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL || 'https://your-project.supabase.co';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'your-anon-key';

export const supabase = createClient(supabaseUrl, supabaseKey);

// Tablas necesarias
export interface BuoyReading {
  buoy_id: string;
  temperature: number;
  ph: number;
  salinity: number;
  latitude: number;
  longitude: number;
  battery_level?: number;
  hydrocarbon_ppm?: number;
  timestamp: string;
}

export interface Buoy {
  id: string;
  buoy_id: string;
  owner_address: string;
  latitude: number;
  longitude: number;
  metadata_hash: string;
  created_at: string;
}

