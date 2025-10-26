const API_URL = 'http://localhost:3001/api';

// Inicializar mapa centrado en Callao, Perú
let map = L.map('map').setView([-12.0564, -77.1181], 12);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '© OpenStreetMap contributors'
}).addTo(map);

let buoys = [
  { id: 'BUOY_001', name: 'Boya Norte Callao', lat: -12.0564, lon: -77.1181 },
  { id: 'BUOY_002', name: 'Boya Sur Callao', lat: -12.0612, lon: -77.1254 },
  { id: 'BUOY_003', name: 'Boya Centro', lat: -12.0523, lon: -77.1123 },
];

const markers = [];

// Cargar boyas en el mapa
function loadBuoys() {
  // Limpiar marcadores existentes
  markers.forEach(marker => map.removeLayer(marker));
  markers.length = 0;
  
  buoys.forEach(buoy => {
    const marker = L.marker([buoy.lat, buoy.lon]).addTo(map);
    marker.bindPopup(`<b>${buoy.name}</b><br>${buoy.id}`);
    markers.push(marker);
  });
}

// Cargar estadísticas
async function loadStats() {
  try {
    const response = await fetch(`${API_URL}/analytics/stats`);
    const stats = await response.json();
    
    document.getElementById('activeBuoys').textContent = stats.active_buoys || 0;
    document.getElementById('totalReadings').textContent = stats.total_readings || 0;
    document.getElementById('avgTemp').textContent = 
      stats.average_temperature ? `${stats.average_temperature}°C` : '-';
    document.getElementById('avgPh').textContent = 
      stats.average_ph ? stats.average_ph.toFixed(2) : '-';
  } catch (error) {
    console.error('Error loading stats:', error);
  }
}

// Cargar predicciones
async function loadPredictions() {
  const predictionsDiv = document.getElementById('predictions');
  predictionsDiv.innerHTML = '<div class="loading">Cargando predicciones...</div>';
  
  try {
    const response = await fetch(`${API_URL}/predictions/fishing-zones`);
    const data = await response.json();
    
    const predictions = data.predictions || [];
    
    if (predictions.length === 0) {
      predictionsDiv.innerHTML = '<div class="loading">No hay predicciones disponibles</div>';
      return;
    }
    
    predictionsDiv.innerHTML = '<div class="predictions-list">';
    
    predictions.slice(0, 5).forEach(prediction => {
      let className = 'prediction-item';
      if (prediction.probability > 0.7) className += ' high';
      else if (prediction.probability > 0.4) className += ' medium';
      else className += ' low';
      
      const probPercent = (prediction.probability * 100).toFixed(0);
      
      predictionsDiv.innerHTML += `
        <div class="${className}">
          <div class="probability">${probPercent}% Probabilidad</div>
          <p><strong>Ubicación:</strong> ${prediction.lat}, ${prediction.lon}</p>
          <p><strong>Temp:</strong> ${prediction.temperature}°C | <strong>pH:</strong> ${prediction.ph}</p>
          <p><strong>Condiciones:</strong> ${prediction.conditions}</p>
          <p><em>${prediction.recommendation}</em></p>
        </div>
      `;
    });
    
    predictionsDiv.innerHTML += '</div>';
    
  } catch (error) {
    console.error('Error loading predictions:', error);
    predictionsDiv.innerHTML = '<div class="alert"><h3>Error</h3><p>No se pudieron cargar las predicciones</p></div>';
  }
}

// Cargar alertas
async function loadAlerts() {
  const alertsDiv = document.getElementById('alerts');
  alertsDiv.innerHTML = '<div class="loading">Cargando alertas...</div>';
  
  try {
    const response = await fetch(`${API_URL}/predictions/anomalies`);
    const data = await response.json();
    
    const alerts = data.anomalies || [];
    
    if (alerts.length === 0) {
      alertsDiv.innerHTML = '<div class="loading">✅ No hay alertas activas</div>';
      return;
    }
    
    alertsDiv.innerHTML = alerts.map(alert => `
      <div class="alert">
        <h3>🚨 ${alert.type}</h3>
        <p><strong>Severidad:</strong> ${alert.severity}%</p>
        <p>${alert.message}</p>
        <p><strong>Acciones recomendadas:</strong></p>
        <ul>
          ${alert.recommended_actions?.map(action => `<li>${action</li>`).join('')}
        </ul>
      </div>
    `).join('');
    
  } catch (error) {
    console.error('Error loading alerts:', error);
    alertsDiv.innerHTML = '<div class="alert"><h3>Error</h3><p>No se pudieron cargar las alertas</p></div>';
  }
}

// Inicializar
loadBuoys();
loadStats();
loadPredictions();
loadAlerts();

// Actualizar cada 30 segundos
setInterval(() => {
  loadStats();
  loadPredictions();
  loadAlerts();
}, 30000);

