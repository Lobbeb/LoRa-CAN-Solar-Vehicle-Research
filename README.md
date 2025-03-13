# 📡 LoRa-CAN Data Logger for Solar-Powered Vehicles

Welcome to the **LoRa-CAN Data Logger** project! This repository contains all the code and resources you need to **read and log CAN bus data over LoRa** using **ESP32** microcontrollers. It’s part of the **Halmstad University Solar Team’s** research on creating **low-power telemetry** in solar-powered vehicles.

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
   git clone https://github.com/YourUsername/LoRa-CAN-DataLogger.git
   cd LoRa-CAN-DataLogger
