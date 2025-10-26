"""
Fishing Zone Predictor
Predice probabilidad de buena pesca basado en parámetros oceánicos
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

class FishingZonePredictor:
    def __init__(self):
        self.model = None
        self.is_trained = False
        
    def prepare_features(self, buoy_data):
        """Extrae features de datos de boyas"""
        features = []
        
        for reading in buoy_data:
            feature_vector = [
                reading.get('temperature', 19.0),
                reading.get('ph', 8.0),
                reading.get('salinity', 35.0),
                reading.get('depth', 40.0) if 'depth' in reading else 40.0,
                reading.get('current_speed', 1.0) if 'current_speed' in reading else 1.0,
                reading.get('latitude', -12.0),
                reading.get('longitude', -77.0),
            ]
            features.append(feature_vector)
        
        return np.array(features)
    
    def classify_conditions(self, reading):
        """Clasificación interpretable de condiciones"""
        temp = reading.get('temperature', 19.0)
        ph = reading.get('ph', 8.0)
        
        if 18 <= temp <= 22 and 7.8 <= ph <= 8.2:
            return "Óptimas"
        elif 15 <= temp <= 25 and 7.5 <= ph <= 8.5:
            return "Buenas"
        else:
            return "Regulares"
    
    def predict_fishing_zones(self, current_buoy_data):
        """
        Predice mejores zonas de pesca basado en datos actuales
        Por ahora devuelve predicciones simuladas basadas en reglas
        """
        if not current_buoy_data:
            return []
        
        results = []
        
        for reading in current_buoy_data:
            temp = reading.get('temperature', 19.0)
            ph = reading.get('ph', 8.0)
            salinity = reading.get('salinity', 35.0)
            
            # Calcular probabilidad basado en parámetros óptimos
            probability = 0.5  # Base
            
            # Factor temperatura óptima: 18-22°C
            if 18 <= temp <= 22:
                probability += 0.25
            elif 15 <= temp <= 25:
                probability += 0.15
            elif temp < 15 or temp > 25:
                probability -= 0.2
            
            # Factor pH óptimo: 7.8-8.2
            if 7.8 <= ph <= 8.2:
                probability += 0.15
            elif 7.5 <= ph <= 8.5:
                probability += 0.08
            else:
                probability -= 0.15
            
            # Factor salinidad: 33-37 ppt es óptimo
            if 33 <= salinity <= 37:
                probability += 0.1
            else:
                probability -= 0.1
            
            # Clamp probabilidad entre 0 y 1
            probability = max(0, min(1, probability))
            
            results.append({
                'lat': reading.get('latitude', -12.05),
                'lon': reading.get('longitude', -77.15),
                'probability': round(probability, 3),
                'temperature': round(temp, 2),
                'ph': round(ph, 2),
                'salinity': round(salinity, 2),
                'conditions': self.classify_conditions(reading),
                'recommendation': self.get_recommendation(probability)
            })
        
        # Ordenar por probabilidad descendente
        results.sort(key=lambda x: x['probability'], reverse=True)
        
        return results
    
    def get_recommendation(self, probability):
        """Genera recomendación basada en probabilidad"""
        if probability > 0.75:
            return 'Zona altamente recomendada para pesca'
        elif probability > 0.5:
            return 'Buena probabilidad de captura'
        elif probability > 0.3:
            return 'Condiciones regulares'
        else:
            return 'Condiciones no favorables'

