/*********
  Rui Santos & Sara Santos - Random Nerd Tutorials
  Modified from the examples of the Arduino LoRa library
  More resources: https://RandomNerdTutorials.com/esp32-lora-rfm95-transceiver-arduino-ide/
*********/

#include <SPI.h>
#include <LoRa.h>

//define the pins used by the transceiver module
#define ss 5
#define rst 14
#define dio0 2

// Kalman filter variables
float kalmanGain = 0.0;
float estimateError = 1.0;
float measurementError = 3.0;
float estimatedRSSI = 0.0;

// SMA filter variables
const int smaWindowSize = 5; // Size of the SMA window
float rssiBuffer[smaWindowSize];
int rssiBufferIndex = 0;
float rssiSum = 0.0;
float smaRSSI;

float packetRSSI;

// Variables
long sbw = 62500; // test 20800, 62500, 250000
int sf = 7; // test 7, 8, 9, 10, 11, 12

int msgCounter = 0;


void setup() {
  //initialize Serial Monitor
  Serial.begin(57600);
  while (!Serial);
  Serial.println("LoRa Receiver");

  //setup LoRa transceiver module
  LoRa.setPins(ss, rst, dio0);
  
  //915-938 for Australia
  //863-870 or 433 for Sweden
  while (!LoRa.begin(915E6)) {
    Serial.println(".");
    delay(500);
  }
   // Change sync word (0xF3) to match the receiver
  // The sync word assures you don't get LoRa messages from other LoRa transceivers
  // ranges from 0-0xFF
  LoRa.setSyncWord(0xF3);
  LoRa.setSignalBandwidth(sbw);
  LoRa.setSpreadingFactor(sf);
  Serial.println("LoRa Initializing OK!");

  // Initialize the SMA buffer
  for (int i = 0; i < smaWindowSize; i++) {
    rssiBuffer[i] = 0.0;
  }
}

float kalmanFilter(float measurement) {

  // Prediction step
  float prediction = estimatedRSSI;
  estimateError += measurementError;

  // Update step
  kalmanGain = estimateError / (estimateError + measurementError);
  estimatedRSSI = prediction + kalmanGain * (measurement - prediction);
  estimateError = (1 - kalmanGain) * estimateError;

  return estimatedRSSI;
}

float SMAfilter(float measurement) {
  // Update the SMA buffer
    rssiSum -= rssiBuffer[rssiBufferIndex];
    rssiBuffer[rssiBufferIndex] = measurement;
    rssiSum += rssiBuffer[rssiBufferIndex];
    rssiBufferIndex = (rssiBufferIndex + 1) % smaWindowSize;
    return rssiSum / smaWindowSize;
}

void updateVariable(String input) {
    input.trim();
    
    if (input.startsWith("sf=")) {
        int newSf = input.substring(3).toInt();
        if (newSf >= 6 && newSf <= 12) { // Valid range for LoRa SF
            sf = newSf;
            LoRa.setSpreadingFactor(sf);
            Serial.printf("Spreading Factor updated to: %d\n", sf);
        } else {
            Serial.println("Invalid SF. Must be between 6 and 12.");
        }
    } else if (input.startsWith("sbw=")) {
        long newSbw = input.substring(4).toInt();
        if (newSbw == 7800 || newSbw == 10400 || newSbw == 15600 ||
            newSbw == 20800 || newSbw == 31250 || newSbw == 41700 ||
            newSbw == 62500 || newSbw == 125000 || newSbw == 250000) {
            sbw = newSbw;
            LoRa.setSignalBandwidth(sbw);
            Serial.printf("Signal Bandwidth updated to: %ld Hz\n", sbw);
        } else {
            Serial.println("Invalid SBW. Use a valid LoRa bandwidth.");
        }
    } else {
        Serial.println("Invalid command. Use 'sf=' or 'sbw=' followed by a value.");
    }
}

void loop() {
  // Change variables with serial input
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    updateVariable(input);
    msgCounter = 0;
  }

  // try to parse packet
  int packetSize = LoRa.parsePacket();
  if (packetSize) {
    msgCounter++;
    Serial.printf("msg id: %d\n", msgCounter);
    // received a packet
    unsigned long currentMillis = millis();
    Serial.print("time ms: ");
    Serial.println(currentMillis);
    // read packet
    while (LoRa.available()) {
      String LoRaData = LoRa.readString();
      Serial.println("LoRa data: " + LoRaData);
    }

    // RSSI of packet
    packetRSSI = LoRa.packetRssi();
    Serial.printf("RSSI: %.4f\n", packetRSSI);

    // Apply Kalman Filter
    estimatedRSSI = kalmanFilter(packetRSSI);
    Serial.printf("Kalman RSSI: %.4f\n", estimatedRSSI);

    // Apply SMA filter
    smaRSSI = SMAfilter(packetRSSI);
    Serial.printf("SMA RSSI: %.4f\n", smaRSSI);
  }
}