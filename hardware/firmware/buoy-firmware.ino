/*
 * Ocean-Sense Network - Firmware para ESP32
 * Boya IoT para monitoreo oceánico
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

// Configuración WiFi
const char* ssid = "YOUR_SSID";
const char* password = "YOUR_PASSWORD";
const char* serverUrl = "http://your-api.com/api/data/ingest";

// IDs únicos de boya
const char* BUOY_ID = "BUOY_001_CALLAO";
const int BUTTON_PIN = 0; // Botón para reset manual

// Sensores
#define ONE_WIRE_BUS 4
#define PH_PIN 34
#define TDS_PIN 35
#define BATTERY_PIN 36

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

HardwareSerial gpsSerial(1);

// Estructura de datos de sensores
struct SensorData {
  float temperature;
  float ph;
  float salinity;
  float latitude;
  float longitude;
  uint32_t timestamp;
  uint16_t batteryLevel;
};

TinyGPSPlus gps;
SensorData sensorData;

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("🌊 Ocean-Sense Network - Buoy Starting");
  
  // Inicializar sensores
  sensors.begin();
  pinMode(PH_PIN, INPUT);
  pinMode(TDS_PIN, INPUT);
  pinMode(BATTERY_PIN, INPUT);
  
  // GPS
  gpsSerial.begin(9600, SERIAL_8N1, 16, 17);
  
  // Conexión WiFi
  connectWiFi();
  
  Serial.println("✅ Buoy initialized");
}

void loop() {
  // Leer sensores
  sensors.requestTemperatures();
  sensorData.temperature = sensors.getTempCByIndex(0);
  
  sensorData.ph = readPH();
  sensorData.salinity = readTDS();
  
  // GPS
  while (gpsSerial.available() > 0) {
    gps.encode(gpsSerial.read());
    if (gps.location.isUpdated()) {
      sensorData.latitude = gps.location.lat();
      sensorData.longitude = gps.location.lng();
    }
  }
  
  sensorData.timestamp = millis();
  sensorData.batteryLevel = analogRead(BATTERY_PIN);
  
  // Enviar datos
  sendDataToBackend();
  
  Serial.println("📊 Data sent");
  
  // Deep sleep por 15 minutos (900,000 ms)
  Serial.println("💤 Going to sleep...");
  esp_sleep_enable_timer_wakeup(15 * 60 * 1000000ULL);
  esp_deep_sleep_start();
}

void connectWiFi() {
  WiFi.begin(ssid, password);
  int attempts = 0;
  
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi connected");
    Serial.print("IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n❌ WiFi failed");
  }
}

void sendDataToBackend() {
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
    return;
  }
  
  HTTPClient http;
  http.begin(serverUrl);
  http.addHeader("Content-Type", "application/json");
  
  String payload = "{";
  payload += "\"buoy_id\":\"" + String(BUOY_ID) + "\",";
  payload += "\"temperature\":" + String(sensorData.temperature, 2) + ",";
  payload += "\"ph\":" + String(sensorData.ph, 2) + ",";
  payload += "\"salinity\":" + String(sensorData.salinity, 2) + ",";
  payload += "\"latitude\":" + String(sensorData.latitude, 6) + ",";
  payload += "\"longitude\":" + String(sensorData.longitude, 6) + ",";
  payload += "\"battery\":" + String(sensorData.batteryLevel) + "}";
  
  int httpCode = http.POST(payload);
  
  if (httpCode > 0) {
    Serial.printf("✅ HTTP Response: %d\n", httpCode);
  } else {
    Serial.printf("❌ HTTP Error: %s\n", http.errorToString(httpCode).c_str());
  }
  
  http.end();
}

float readPH() {
  int rawValue = analogRead(PH_PIN);
  float voltage = rawValue * (3.3 / 4095.0);
  
  // Calibración: pH = 7 + (2.5 - voltage) / 0.18
  float ph = 7.0 + (2.5 - voltage) / 0.18;
  
  return ph;
}

float readTDS() {
  int rawValue = analogRead(TDS_PIN);
  float voltage = rawValue * (3.3 / 4095.0);
  
  // TDS (ppm) = (133.42 * voltage^3 - 255.86 * voltage^2 + 857.39 * voltage) * 0.5
  float tds = (133.42 * pow(voltage, 3) - 255.86 * pow(voltage, 2) + 857.39 * voltage) * 0.5;
  
  // Conversión a salinidad (ppt) aproximada
  float salinity = tds * 0.001;
  
  return salinity;
}

