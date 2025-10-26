// Simple Starknet client helper for the frontend
// - Loads contracts config from ../config/contracts.json
// - Fetches ABI files from the public /abis/ folder (served by your frontend)
// - Creates Contract instances using RpcProvider from 'starknet'

import { RpcProvider, Contract } from 'starknet';
import contractsConfig from '../config/contracts.json';

const provider = new RpcProvider({ nodeUrl: contractsConfig.rpcUrl });

async function loadAbi(path) {
  // Fetch ABI file from the frontend public path. Adjust if your bundler serves files differently.
  const res = await fetch(path);
  if (!res.ok) throw new Error(`Failed to load ABI at ${path}: ${res.statusText}`);
  return await res.json();
}

export async function getBuoyRegistryContract() {
  const entry = contractsConfig.contracts.buoyRegistry;
  const abiJson = await loadAbi(entry.abi);
  const abi = abiJson.abi ?? abiJson; // support both full contract_class and plain ABI files
  return new Contract(abi, entry.address, provider);
}

// Example: read-only call
export async function fetchTotalBuoys() {
  const contract = await getBuoyRegistryContract();
  const res = await contract.get_total_buoys();
  return res;
}

// Export provider for other modules
export { provider };
