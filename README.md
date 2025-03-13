# 📡 LoRa-CAN Data Logger for Solar-Powered Vehicles

Welcome to the **LoRa-CAN Data Logger** project! This repository contains all the code and resources you need to **read and log CAN bus data over LoRa** using **ESP32** microcontrollers. It's part of the **Halmstad University Solar Team's** research on creating **low-power telemetry** in solar-powered vehicles.

---

## 📜 Table of Contents
1. [Overview](#-overview)
2. [Repository Contents](#-repository-contents)
3. [Features](#-features)
4. [Installation & Setup](#-installation--setup)
5. [Usage](#-usage)
6. [Hardware Requirements](#-hardware-requirements)
7. [Data Storage & Analysis](#-data-storage--analysis)
8. [Contributors](#-contributors)
9. [License](#-license)

---

## ✨ Overview
- **Goal**: Efficiently transmit **CAN bus** data using **LoRa** for long-range, low-power monitoring in a solar-powered racing car.
- **Key Focus**: Minimizing energy consumption while ensuring reliable data transmission.
- **Context**: Part of the **Halmstad University Solar Team** project, aiming to enhance telemetry for the **World Solar Challenge**.

---

## 📂 Repository Contents
1. **`LoRa_code.zip`**  
   - Contains firmware/scripts for **ESP32 + LoRa** communication.
   - Handles CAN message transmission and reception over **LoRa**.
   
2. **`read_data.py`**  
   - A **Python** script to read **LoRa-transmitted CAN data** from a serial port.
   - Extracts/logs:
     - **Message ID**, **Timestamp**, **LoRa data**, **RSSI**, **Kalman-filtered RSSI**, **SMA RSSI**
   - Outputs data in **CSV** format for analysis.

3. **`README.md`**  
   - Comprehensive documentation of this project.

---

## 🚀 Features
- **CAN-to-LoRa** communication for real-time telemetry.
- **Configurable** LoRa parameters (spreading factor, bandwidth, etc.).
- **Energy-efficient** data collection suitable for **battery-powered** or **solar** setups.
- **RSSI filtering** (Kalman & SMA) for stable signal-strength readings.
- **CSV logs** for offline inspection and analysis.

---

## 🛠 Installation & Setup
1. **Clone or Download** the repository:
   ```sh
   git clone https://github.com/Lobbe/LoRa-CAN-DataLogger.git
   cd LoRa-CAN-DataLogger
   ```

2. **ESP32 Environment**:
   - Install Arduino IDE or PlatformIO.
   - Add support for ESP32 boards.

3. **Python Environment** (for read_data.py):
   - Install Python 3.
   - Install pyserial:
     ```sh
     pip install pyserial
     ```

---

## 📊 Usage
1. **Unzip or open `LoRa_code.zip`** in your preferred IDE (Arduino/PlatformIO).
   
2. **Configure the sketch**:
   - Ensure your LoRa frequency matches your region (EU: ~868 MHz, AU/US: ~915 MHz).
   - Adjust Spreading Factor, Bandwidth, etc. to suit your test conditions.
   - Check any CAN bus speed settings.
   
3. **Upload the code** to your Sender ESP32 and Receiver ESP32:
   - Sender reads CAN data and transmits via LoRa.
   - Receiver captures LoRa packets and forwards them to serial.

4. **Connect your ESP32 LoRa receiver** to your computer.

5. **Adjust the serial port settings** in `read_data.py`:
   ```python
   SERIAL_PORT = 'COM7'  # Change this to match your device (e.g., '/dev/ttyUSB0' on Linux)
   BAUD_RATE = 57600
   ```

6. **Run the script**:
   ```sh
   python read_data.py
   ```

7. **Data will be logged to a CSV file**, automatically named based on the timestamp.

---

## 🔧 Hardware Requirements
- **ESP32 + LoRa Module** (e.g., Heltec/Wemos LoRa32)
- **CAN Transceiver** (e.g., SN65HVD230)
- **Power Supply (12V)** for ESP32 system
- **Antenna (16cm, 868MHz)** for LoRa transmission

---

## 📊 Data Storage & Analysis
- The script logs data in CSV format for **further signal strength and packet loss analysis**.
- Future work includes **dynamic LoRa parameter tuning** for real-time power optimization.

---

## 👨‍💻 Contributors
- **William Olsson**
- **Ruben Croall**

---

## 📄 License
[Include your license information here]
