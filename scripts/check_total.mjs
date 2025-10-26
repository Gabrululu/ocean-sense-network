import fs from 'fs/promises';
import path from 'path';
import { RpcProvider, Contract } from 'starknet';

async function main() {
  const cfgPath = path.resolve('frontend', 'config', 'contracts.json');
  const cfgRaw = await fs.readFile(cfgPath, 'utf8');
  const cfg = JSON.parse(cfgRaw);

  const buoyEntry = cfg.contracts && cfg.contracts.buoyRegistry;
  if (!buoyEntry) {
    throw new Error('buoyRegistry entry not found in config');
  }

  const abiPath = path.resolve('frontend', buoyEntry.abi.replace(/^[\/]/, ''));
  const abiRaw = await fs.readFile(abiPath, 'utf8');
  const abiJson = JSON.parse(abiRaw);
  const abi = abiJson.abi ?? abiJson;

  const provider = new RpcProvider({ nodeUrl: cfg.rpcUrl });
  const contract = new Contract(abi, buoyEntry.address, provider);

  console.log('Calling get_total_buoys on', buoyEntry.address);
  const res = await contract.get_total_buoys();
  console.log('Raw result:', res);
}

main().catch((err) => {
  console.error('Error in check_total:', err);
  process.exit(1);
});
