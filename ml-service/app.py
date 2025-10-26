"""
Ocean-Sense Network ML Service
Proporciona predicciones de zonas de pesca y detección de anomalías
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import pandas as pd
from models.predictor import FishingZonePredictor
from models.anomaly_detector import OceanAnomalyDetector

app = Flask(__name__)
CORS(app)

# Inicializar modelos
predictor = FishingZonePredictor()
anomaly_detector = OceanAnomalyDetector()

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'ok',
        'service': 'Ocean-Sense ML Service'
    })

@app.route('/predict/fishing', methods=['POST'])
def predict_fishing_zones():
    """Predice mejores zonas de pesca basado en datos actuales"""
    try:
        data = request.json.get('data', [])
        
        # Generar predicciones
        predictions = predictor.predict_fishing_zones(data)
        
        return jsonify({
            'predictions': predictions,
            'timestamp': pd.Timestamp.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/detect/anomalies', methods=['POST'])
def detect_anomalies():
    """Detecta anomalías en datos oceánicos"""
    try:
        reading = request.json
        zone = request.json.get('zone', 'CALLAO_NORTH')
        
        anomalies = anomaly_detector.detect_anomalies(reading, zone)
        
        if anomalies:
            alerts = [anomaly_detector.generate_alert(anomaly, reading.get('location', {})) 
                     for anomaly in anomalies]
            return jsonify({
                'anomalies': alerts,
                'has_anomalies': True
            })
        else:
            return jsonify({
                'anomalies': [],
                'has_anomalies': False
            })
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/train/fishing', methods=['POST'])
def train_fishing_model():
    """Entrena modelo de predicción de pesca (para futuro)"""
    return jsonify({
        'message': 'Training endpoint not yet implemented',
        'status': 'coming_soon'
    })

if __name__ == '__main__':
    print("🌊 Ocean-Sense ML Service starting...")
    app.run(host='0.0.0.0', port=5000, debug=True)
