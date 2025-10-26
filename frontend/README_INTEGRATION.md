# Integración Starknet (frontend)

Este documento explica cómo extraer los ABIs compilados y conectar el frontend a los contratos desplegados en Sepolia.

Requisitos:
- `scarb` instalado en el entorno donde compilas los contratos.
- `node` / `npm` para el frontend.

Pasos rápidos:

1) Compilar contratos (desde la raíz del repo):

```bash
scarb build
```

2) Copiar/artifacts ABI a `frontend/abis/` (comando genérico):

```bash
# crea carpeta si no existe
mkdir -p frontend/abis

# intenta copiar contract_class.json generados (ajusta la ruta si están en target/release o target/dev)
cp target/dev/*_contract_class.json frontend/abis/ || cp target/release/*_contract_class.json frontend/abis/ || true

# (opcional) Extraer solo la propiedad `abi` a archivos *_abi.json usando jq
for f in frontend/abis/*_contract_class.json; do
  base=$(basename "$f" _contract_class.json)
  jq '.abi' "$f" > "frontend/abis/${base}_abi.json"
done
```

3) Rellena `frontend/config/contracts.json` con las direcciones reales (0x...) que obtuviste al desplegar con `sncast deploy`.

4) Instala dependencias del frontend e inicia el servidor de desarrollo:

```bash
cd frontend
npm install
# Si tu frontend tiene un script 'dev' o 'start', úsalo. Por ejemplo:
npm run dev || npm start || true
```

5) Uso en código (ejemplo): importa `frontend/src/starknetClient.js` y llama a `fetchTotalBuoys()` para probar una llamada de solo lectura.

Notas:
- El ejemplo carga ABI vía `fetch()` desde `/abis/...` para ser compatible con bundlers que sirven contenido estático. Si tu compilador/bundler soporta `import` de JSON, puedes importar ABI directamente.
- Si los nombres de los archivos en `target/` difieren, adapta el `cp`/`jq` anterior.

Si quieres, puedo extraer automáticamente los ABIs desde `target/` y crear los archivos JSON `frontend/abis/*` aquí; dime si quieres que lo haga y ejecutaré los comandos.
