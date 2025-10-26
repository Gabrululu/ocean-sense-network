"""
Ocean Anomaly Detector
Detecta anomalías en parámetros oceánicos (derrames, acidificación, etc.)
"""

import numpy as np
from sklearn.ensemble import IsolationForest
from datetime import datetime

class OceanAnomalyDetector:
    def __init__(self):
        self.iso_forest = IsolationForest(
            contamination=0.05,  # 5% de datos se esperan anómalos
            random_state=42
        )
        self.baseline_stats = {
            'CALLAO_NORTH': {
                'temp_mean': 19.5,
                'temp_std': 1.2,
                'ph_mean': 8.0,
                'ph_std': 0.15,
                'salinity_mean': 35.0,
                'salinity_std': 1.5,
            },
            'CALLAO_SOUTH': {
                'temp_mean': 19.3,
                'temp_std': 1.3,
                'ph_mean': 8.0,
                'ph_std': 0.15,
                'salinity_mean': 34.8,
                'salinity_std': 1.5,
            }
        }
    
    def detect_anomalies(self, current_reading, zone='CALLAO_NORTH'):
        """
        Detecta anomalías en tiempo real
        Retorna: tipo de anomalía, severidad (0-100), explicación
        """
        baseline = self.baseline_stats.get(zone)
        if not baseline:
            return None
        
        anomalies = []
        
        # Método 1: Z-score (desviación estadística)
        temp = current_reading.get('temperature', 19.0)
        ph = current_reading.get('ph', 8.0)
        salinity = current_reading.get('salinity', 35.0)
        
        temp_z = abs((temp - baseline['temp_mean']) / baseline['temp_std'])
        ph_z = abs((ph - baseline['ph_mean']) / baseline['ph_std'])
        sal_z = abs((salinity - baseline['salinity_mean']) / baseline['salinity_std'])
        
        if temp_z > 3:  # Más de 3 desviaciones estándar
            anomalies.append({
                'type': 'TEMPERATURA_ANOMALA',
                'severity': min(int(temp_z * 20), 100),
                'explanation': f"Temperatura {temp:.1f}°C está {temp_z:.1f}σ fuera de lo normal ({baseline['temp_mean']:.1f}°C)"
            })
        
        if ph_z > 2.5:
            severity = min(int(ph_z * 30), 100)
            if ph < baseline['ph_mean'] - 0.5:
                anomalies.append({
                    'type': 'ACIDIFICACION_DETECTADA',
                    'severity': severity,
                    'explanation': f"pH {ph:.2f} indica posible acidificación oceánica"
                })
            else:
                anomalies.append({
                    'type': 'PH_ANOMALO',
                    'severity': severity,
                    'explanation': f"pH {ph:.2f} desviado del rango normal"
                })
        
        # Detección específica: Derrame de petróleo
        hydrocarbon_ppm = current_reading.get('hydrocarbon_ppm', 0)
        if hydrocarbon_ppm > 5:  # Umbral de detección
            anomalies.append({
                'type': 'DERRAME_PROBABLE',
                'severity': 95,
                'explanation': f"Hidrocarburos detectados: {hydrocarbon_ppm:.1f} ppm",
                'action': 'ALERTA_INMEDIATA'
            })
        
        return anomalies if anomalies else None
    
    def generate_alert(self, anomaly, buoy_location):
        """
        Genera alerta estructurada para sistema de notificaciones
        """
        if anomaly['severity'] >= 80:
            priority = 'CRITICAL'
        elif anomaly['severity'] >= 50:
            priority = 'HIGH'
        else:
            priority = 'MEDIUM'
        
        alert = {
            'priority': priority,
            'type': anomaly['type'],
            'location': buoy_location,
            'severity': anomaly['severity'],
            'message': anomaly['explanation'],
            'timestamp': datetime.now().isoformat(),
            'recommended_actions': self.get_recommended_actions(anomaly['type'])
        }
        
        return alert
    
    def get_recommended_actions(self, anomaly_type):
        """Obtiene acciones recomendadas según tipo de anomalía"""
        actions = {
            'DERRAME_PROBABLE': [
                'Notificar a DICAPI (Autoridad Marítima)',
                'Activar protocolo de contención',
                'Alertar a embarcaciones cercanas',
                'Desplegar boyas adicionales en perímetro'
            ],
            'ACIDIFICACION_DETECTADA': [
                'Monitorear evolución cada 30 minutos',
                'Alertar a cooperativas pesqueras',
                'Registrar en base de datos científica'
            ],
            'TEMPERATURA_ANOMALA': [
                'Verificar con boyas adyacentes',
                'Evaluar posible inicio de El Niño',
                'Actualizar modelos predictivos'
            ]
        }
        
        return actions.get(anomaly_type, ['Monitorear situación'])

