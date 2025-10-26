// Datos simulados de 8 boyas en costa peruana
const buoysData = [
    { id: "BUOY_CALLAO_NORTE", name: "Callao Norte", lat: -12.05, lon: -77.15, temp: 19.2, ph: 7.2, salinity: 33.1, battery: 85, alert: true },
    { id: "BUOY_ANCON", name: "Ancón", lat: -11.76, lon: -77.18, temp: 18.8, ph: 8.1, salinity: 35.2, battery: 92, alert: false },
    { id: "BUOY_HUACHO", name: "Huacho", lat: -11.11, lon: -77.61, temp: 18.3, ph: 8.0, salinity: 35.0, battery: 78, alert: false },
    { id: "BUOY_BARRANCA", name: "Barranca", lat: -10.75, lon: -77.76, temp: 19.7, ph: 8.2, salinity: 35.4, battery: 88, alert: false },
    { id: "BUOY_CHIMBOTE", name: "Chimbote", lat: -9.08, lon: -78.59, temp: 17.9, ph: 8.1, salinity: 35.1, battery: 95, alert: false },
    { id: "BUOY_TRUJILLO", name: "Trujillo", lat: -8.11, lon: -79.03, temp: 18.4, ph: 8.0, salinity: 35.3, battery: 81, alert: false },
    { id: "BUOY_PACASMAYO", name: "Pacasmayo", lat: -7.40, lon: -79.57, temp: 19.2, ph: 8.1, salinity: 35.2, battery: 90, alert: false },
    { id: "BUOY_MANCORA", name: "Máncora", lat: -4.10, lon: -81.05, temp: 22.1, ph: 8.2, salinity: 35.6, battery: 87, alert: false }
];

// Predicciones de IA
const predictions = [
    { zone: "Trujillo - Pacasmayo", probability: 87, conditions: "Óptimas", temp: 18.8, ph: 8.1 },
    { zone: "Chimbote Norte", probability: 82, conditions: "Muy Buenas", temp: 17.9, ph: 8.1 },
    { zone: "Huacho - Barranca", probability: 75, conditions: "Buenas", temp: 19.0, ph: 8.1 },
    { zone: "Ancón - Chancay", probability: 68, conditions: "Buenas", temp: 18.5, ph: 8.0 },
    { zone: "Máncora", probability: 91, conditions: "Excelentes", temp: 22.1, ph: 8.2 }
];

// Alertas
const alerts = [
    { type: "🚨 DERRAME PROBABLE", severity: "critical", zone: "Callao Norte", time: "Hace 2 horas", 
      description: "Hidrocarburos detectados: 12.3 ppm. pH anormalmente bajo (7.2). Acción inmediata requerida." }
];

// Inicializar mapa
const map = L.map('map').setView([-10.0, -78.0], 6);
L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png').addTo(map);

// Iconos
const normalIcon = L.divIcon({
    html: '<div style="background: #00d4ff; width: 20px; height: 20px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 10px rgba(0,212,255,0.5);"></div>',
    className: '', iconSize: [20, 20]
});

const alertIcon = L.divIcon({
    html: '<div style="background: #ff4757; width: 24px; height: 24px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 15px rgba(255,71,87,0.8);"></div>',
    className: '', iconSize: [24, 24]
});

// Agregar boyas al mapa
buoysData.forEach(buoy => {
    const icon = buoy.alert ? alertIcon : normalIcon;
    const marker = L.marker([buoy.lat, buoy.lon], { icon }).addTo(map);
    marker.bindPopup(`<b>${buoy.name}</b><br>Temp: ${buoy.temp}°C | pH: ${buoy.ph}`);
});

// Círculos de predicción
predictions.forEach(pred => {
    L.circle([buoysData.find(b => b.name.includes(pred.zone.split(' ')[0])).lat, 
              buoysData.find(b => b.name.includes(pred.zone.split(' ')[0])).lon], {
        color: pred.probability > 80 ? '#00ff88' : '#00d4ff',
        fillColor: pred.probability > 80 ? '#00ff88' : '#00d4ff',
        fillOpacity: 0.15,
        radius: 30000
    }).addTo(map);
});

// Renderizar lista de boyas
document.getElementById('buoyList').innerHTML = buoysData.map(buoy => `
    <div class="buoy-item ${buoy.alert ? 'alert' : ''}">
        <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
            <strong>${buoy.name}</strong>
            <span style="padding: 0.25rem 0.75rem; border-radius: 12px; font-size: 0.75rem; 
                ${buoy.alert ? 'background: rgba(255,71,87,0.2); color: #ff4757;' : 'background: rgba(0,255,136,0.2); color: #00ff88;'}">
                ${buoy.alert ? '⚠️ ALERTA' : '✓ Activa'}
            </span>
        </div>
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.5rem; font-size: 0.9rem;">
            <div>Temp: <strong>${buoy.temp}°C</strong></div>
            <div>pH: <strong>${buoy.ph}</strong></div>
            <div>Batería: <strong>${buoy.battery}%</strong></div>
        </div>
    </div>
`).join('');

// Renderizar predicciones
document.getElementById('predictions').innerHTML = predictions
    .sort((a, b) => b.probability - a.probability)
    .map(pred => `
    <div class="prediction-item">
        <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
            <div>
                <h3 style="margin: 0; font-size: 1.1rem;">${pred.zone}</h3>
                <p style="margin: 0.25rem 0 0 0; font-size: 0.85rem; color: rgba(255,255,255,0.6);">
                    ${pred.conditions} • Temp: ${pred.temp}°C
                </p>
            </div>
            <div class="probability">${pred.probability}%</div>
        </div>
        <div style="width: 100%; height: 8px; background: rgba(255,255,255,0.1); border-radius: 4px; margin-top: 0.5rem;">
            <div style="height: 100%; background: linear-gradient(90deg, #00d4ff, #00ff88); border-radius: 4px; width: ${pred.probability}%;"></div>
        </div>
    </div>
`).join('');

// Renderizar alertas
document.getElementById('alerts').innerHTML = alerts.map(alert => `
    <div class="alert-item ${alert.severity}">
        <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
            <span style="font-weight: 600; color: #ff4757;">${alert.type}</span>
            <span style="font-size: 0.85rem; color: rgba(255,255,255,0.5);">${alert.time}</span>
        </div>
        <p style="margin: 0;"><strong>${alert.zone}:</strong> ${alert.description}</p>
    </div>
`).join('');

