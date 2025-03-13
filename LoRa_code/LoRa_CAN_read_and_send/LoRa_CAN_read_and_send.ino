#include <LoRa.h>
#include <ESP32-TWAI-CAN.hpp>
#include <Arduino.h>
#include "SD_card.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


//define the pins used by the transceiver module
#define ss 5
#define rst 14
#define dio0 2

// define pins for CAN tranceiver
#define CAN_TX		16
#define CAN_RX		4

// define variables
float battery_volt;
float battery_current;
float battery_cell_LOW_volt;
float battery_cell_HIGH_volt;
float battery_cell_AVG_volt;
float battery_cell_LOW_temp;
float battery_cell_HIGH_temp;
float battery_cell_AVG_temp;
float battery_cell_ID_HIGH_temp;
float battery_cell_ID_LOW_temp;
float BMS_temp;

float velocity;
float distance_travelled;
float motor_current;
float motor_temp;
float motor_controller_temp;
float driverRPM;
float driver_current;

float MPPT1_watt;
float MPPT2_watt;
float MPPT3_watt;
float MPPT_total_watt;

CanFrame msg;

int SDcardFlag = 1;

// Variables to change when collecting data

// How many messages we want to send
#define MAX_NR_MSG 50
int counter = 0;

// Minimum transmitting frequency
float sendInterval = 0.1;

// Spreading factor (6, 7, 8, 9, 10, 11, 12)
int sf = 7;

// Signal bandwidth (10.4e3, 15.6e3, 20.8e3, 31.25e3, 41.7e3, 62.5e3, 125e3, 250e3)
long sbw = 62500;

void assignCAN2variable() {

  // For MPPT power out
  double voltOut = ((double)(msg.data[4] * 256 + msg.data[5]))/100;
        double currentOut;
        if (msg.data[6] >= 128)
          currentOut = ((double)((msg.data[6] - 256) * 256 + msg.data[7]))*0.0005;
        else
          currentOut = ((double)(msg.data[6] * 256 + msg.data[7]))*0.0005;
  
  switch(msg.identifier) {
    case 0x402:
      motor_current = *((float*)(msg.data+4));
      break;
    case 0x403:
      velocity = *((float*)(msg.data+4));
      break;
    case 0x40B:
      motor_controller_temp = *((float*)(msg.data+4));
      motor_temp = *((float*)(msg.data));
      break;
    case 0x40E:
      distance_travelled = *((float*)(msg.data));
      break;

    // Battery temperatures
    case 0x601:
      BMS_temp = msg.data[1];
      battery_cell_HIGH_temp = msg.data[2];
      battery_cell_LOW_temp = msg.data[3];
      battery_cell_AVG_temp = msg.data[4];
      battery_cell_ID_HIGH_temp = msg.data[5];
      battery_cell_ID_LOW_temp = msg.data[6];
      break;

    // Battery voltage and current
    case 0x602:
      if(msg.data[0] >= 128)
        battery_current = ((double)(msg.data[0] - 256) * 256 + msg.data[1])/10;
      else
        battery_current = ((double)(msg.data[0] * 256 + msg.data[1]))/10;
      battery_volt = ((double)(msg.data[2] * 256 + msg.data[3]))/10;
      battery_cell_LOW_volt = ((double)(msg.data[4] * msg.data[5]))/10000;
      battery_cell_HIGH_volt = ((double)(msg.data[6] * msg.data[7]))/10000;

      // Store values in arrays for power consumption calculations
      if (sample_count < MAX_SAMPLES) {
        battery_current_array[sample_count] = battery_current;
        battery_voltage_array[sample_count] = battery_volt;
        sample_count++;
      }
      break;

    case 0x603:
      battery_cell_AVG_volt = ((double)(msg.data[0] * 256 + msg.data[1]))/10000;
      break;
      
    //MPPT power out (watt)
    case 0x200:
      MPPT1_watt = voltOut * currentOut;
      break;
    case 0x210:
      MPPT2_watt = voltOut * currentOut;
      break;
    case 0x220:
      MPPT3_watt = voltOut * currentOut;
      break;
    
    //Blinkers, hazards, and brake
    case 0x176:
      left_blinker = msg.data[0];
      right_blinker = msg.data[1];
      hazard_light = msg.data[2];
      brake_light = msg.data[3];
      Serial.printf("left: %d, right %d, hazard: %d, brake: %d", left_blinker, right_blinker, hazard_light, brake_light);
      Serial.println();

    case 0x501:
      driver_current = *((float*)(msg.data+4));
      driverRPM = *((float*)(msg.data));
      Serial.printf("Driver current: %.2f, Driver RPM: %.2f", driver_current, driverRPM);
      Serial.println();
      
    default:
      //Serial.println("No matching identifier");
      break;
  }
  MPPT_total_watt = MPPT1_watt + MPPT2_watt + MPPT3_watt;
}

void prepareAndWrite2SD() {
  char buffer[512];
  snprintf(buffer, sizeof(buffer),
            "%.2f %.2f "
            "%.2f %.2f "
            "%.2f %.2f %.2f "
            "%.2f %.2f %.2f "
            "%.2f %.2f %.2f "
            "%.2f %.2f %.2f "
            "%.2f %.2f %.2f %.2f \n",
            velocity, distance_travelled, 
            battery_volt, battery_current, 
            battery_cell_LOW_volt, battery_cell_HIGH_volt, battery_cell_AVG_volt,
            battery_cell_LOW_temp, battery_cell_HIGH_temp, battery_cell_AVG_temp,
            battery_cell_ID_HIGH_temp, battery_cell_ID_LOW_temp, BMS_temp,
            motor_current, motor_temp, motor_controller_temp,
            MPPT1_watt, MPPT2_watt, MPPT3_watt, MPPT_total_watt);
  write2SDcard(buffer, SDcardFlag);
}

void writeVariables2SDcard() {
  char buffer[256];
  snprintf(buffer, sizeof(buffer),
            "sending interval: %.2f, spreading factor: %d, bandwidth: %l\n",
            sendInterval, sf, sbw);
  write2SDcard(buffer, SDcardFlag);
}

void sendLoRaData() {

    while(LoRa.beginPacket() == 0) {
      Serial.println("Waiting for radio...");
      delay(100);
    }

    LoRa.beginPacket();
    
    LoRa.print(velocity); LoRa.print(" ");
    LoRa.print(distance_travelled); LoRa.print(" ");
    LoRa.print(battery_volt); LoRa.print(" ");
    LoRa.print(battery_current); LoRa.print(" ");
    LoRa.print(battery_cell_LOW_volt); LoRa.print(" ");
    LoRa.print(battery_cell_HIGH_volt); LoRa.print(" ");
    LoRa.print(battery_cell_AVG_volt); LoRa.print(" ");
    LoRa.print(battery_cell_LOW_temp); LoRa.print(" ");
    LoRa.print(battery_cell_HIGH_temp); LoRa.print(" ");
    LoRa.print(battery_cell_AVG_temp); LoRa.print(" ");
    LoRa.print(battery_cell_ID_HIGH_temp); LoRa.print(" ");
    LoRa.print(battery_cell_ID_LOW_temp); LoRa.print(" ");
    LoRa.print(BMS_temp); LoRa.print(" ");
    LoRa.print(motor_current); LoRa.print(" ");
    LoRa.print(motor_temp); LoRa.print(" ");
    LoRa.print(motor_controller_temp); LoRa.print(" ");
    LoRa.print(MPPT1_watt); LoRa.print(" ");
    LoRa.print(MPPT2_watt); LoRa.print(" ");
    LoRa.print(MPPT3_watt); LoRa.print(" ");
    LoRa.print(MPPT_total_watt);

    LoRa.endPacket();
}

void blinkLEDs() {

  unsigned long currentMillis = millis();

  if(currentMillis - previousMillisLEDs >= blinkInterval) {
    previousMillisLEDs = currentMillis;
    ledState = !ledState;

    // Blink LEDS
    if (left_blinker > 0.0 || hazard_light > 0.0) {
    digitalWrite(26, ledState);
    }
    else
      digitalWrite(26, LOW);
    
    if (right_blinker > 0.0 || hazard_light > 0.0) {
      digitalWrite(12, ledState);
    }
    else
      digitalWrite(12, LOW);
    
    if (brake_light > 0.0) {
      digitalWrite(25, HIGH);
    }
    else
      digitalWrite(25, LOW);
  }
}

void updateVariable(String input) {
    input.trim();
    
    if (input.startsWith("sendInterval=")) {
        sendInterval = input.substring(13).toFloat();
        Serial.print("sendInterval updated: ");
        Serial.println(sendInterval);
    } else if (input.startsWith("sf=")) {
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

void setup() {

  //initialize Serial Monitor
  Serial.begin(115200);
  while (!Serial);
  Serial.println("LoRa Sender");

  //setup LoRa transceiver module
  LoRa.setPins(ss, rst, dio0);

  // Set pins
  ESP32Can.setPins(CAN_TX, CAN_RX);
	
  // You can set custom size for the queues - these are default
  ESP32Can.setRxQueueSize(10);
  ESP32Can.setTxQueueSize(10);
  ESP32Can.setSpeed(ESP32Can.convertSpeed(500));

  if(ESP32Can.begin()) {
    Serial.println("CAN bus started!");
  } else {
    Serial.println("CAN bus failed!");
  }

  if(ESP32Can.begin(ESP32Can.convertSpeed(500), CAN_TX, CAN_RX, 10, 10)) {
    Serial.println("CAN bus speed 500!");
  } else {
    Serial.println("CAN bus failed!");
  }

  //915-938 for Australia
  //863-870 or 433 for Sweden
  while (!LoRa.begin(915E6)) {
    Serial.println(".");
    delay(500);
  }

  // Set spreading factor
  LoRa.setSpreadingFactor(sf);
  // Set bandwidth
  LoRa.setSignalBandwidth(sbw);
  writeVariables2SDcard();
  SDcardFlag = 0;

  // The sync word assures you don't get LoRa messages from other LoRa transceivers
  // ranges from 0-0xFF
  LoRa.setSyncWord(0xF3);
  Serial.println("LoRa Initializing OK!");
}

void loop() {

  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    updateVariable(input);
    counter = 0;
  }

  static clock_t lastSendTime = 0;

  if (ESP32Can.readFrame(msg, 0)) {
    //Serial.printf("Received CAN ID: %3X \r\n", msg.identifier);

    // Assign CAN data to specified variable based on identifier
    assignCAN2variable();

    clock_t currentTime = clock();
    double timeElapsed = ((double)(currentTime - lastSendTime))/CLOCKS_PER_SEC;

    if (timeElapsed >= sendInterval) {

      // Prepare const char of our variables and save to SD card
      prepareAndWrite2SD();
      
      //Serial.println("Wrote to SD");

      // Send with LoRa
      sendLoRaData();
      Serial.print(counter);
      Serial.println(" CAN sent with LoRa");
      lastSendTime = currentTime;

      if (counter < MAX_NR_MSG) {
        counter++;
      } else {
        Serial.println("Max messages reached. Send commands to change variables.");

        while (true) {
            if (Serial.available()) {
                String input = Serial.readStringUntil('\n');
                updateVariable(input);
                //writeVariables2SDcard();
                
                // Allow the user to continue execution
                if (input == "continue") {
                    counter = 0;
                    Serial.println("Continuing execution.");
                    break;
                }
            }
        }
      }
    }
  }
}
