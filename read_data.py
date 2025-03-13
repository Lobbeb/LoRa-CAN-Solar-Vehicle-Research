import serial
import csv
import datetime
import re
import signal
import sys

# Adjust COM port & baud rate to match your setup
SERIAL_PORT = 'COM7'
BAUD_RATE = 57600

# Regex patterns
MSG_ID_REGEX = re.compile(r"msg id:\s*(\d+)")
TIME_MS_REGEX = re.compile(r"time ms:\s*([\d\.]+)")
LORA_DATA_REGEX = re.compile(r"LoRa data:\s*(.+)")
RSSI_REGEX = re.compile(r"RSSI:\s*([-\d\.]+)")
KALMAN_RSSI_REGEX = re.compile(r"Kalman RSSI:\s*([-\d\.]+)")
SMA_RSSI_REGEX = re.compile(r"SMA RSSI:\s*([-\d\.]+)")


def signal_handler(sig, frame):
    """Handle Ctrl+C gracefully."""
    print("\nClosing serial connection and exiting...")
    if ser.is_open:
        ser.close()
    sys.exit(0)


def main():
    global ser
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)  # Set timeout to prevent blocking
    print(f"Opened {SERIAL_PORT} at {BAUD_RATE} baud.")
    
    # Register signal handler for Ctrl+C
    signal.signal(signal.SIGINT, signal_handler)
    
    # Generate a unique filename with timestamp
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    csv_filename = f"lora_receiver_{timestamp}.csv"
    print(f"Logging data to: {csv_filename}")
    
    # Open CSV file
    with open(csv_filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["msg_id", "time_ms", "LoRa_kata", "RSSI", "kalman_RSSI", "sma_RSSI"])
        
        packet_data = {}
        
        try:
            while True:
                line = ser.readline().decode('utf-8', errors='replace').strip()
                if not line:
                    continue  # Skip empty lines
                
                # Match message ID
                msg_match = MSG_ID_REGEX.search(line)
                if msg_match:
                    packet_data["msg_id"] = int(msg_match.group(1))
                
                # Match time in ms
                time_match = TIME_MS_REGEX.search(line)
                if time_match:
                    packet_data["time_ms"] = float(time_match.group(1))
                
                # Match LoRa data
                lora_match = LORA_DATA_REGEX.search(line)
                if lora_match:
                    lora_data = lora_match.group(1).strip()
                    packet_data["lora_data"] = lora_data if '\ufffd' not in lora_data else ""  # Ignore gibberish symbols
                
                # Match RSSI
                rssi_match = RSSI_REGEX.search(line)
                if rssi_match:
                    packet_data["rssi"] = float(rssi_match.group(1))
                
                # Match Kalman RSSI
                kalman_match = KALMAN_RSSI_REGEX.search(line)
                if kalman_match:
                    packet_data["kalman_rssi"] = float(kalman_match.group(1))
                
                # Match SMA RSSI
                sma_match = SMA_RSSI_REGEX.search(line)
                if sma_match:
                    packet_data["sma_rssi"] = float(sma_match.group(1))
                
                # If all required fields are present, write to CSV
                if all(key in packet_data for key in ["msg_id", "time_ms", "lora_data", "rssi", "kalman_rssi", "sma_rssi"]):
                    writer.writerow([
                        packet_data["msg_id"],
                        packet_data["time_ms"],
                        packet_data.get("lora_data", ""),  # Ensure empty string if gibberish
                        packet_data["rssi"],
                        packet_data["kalman_rssi"],
                        packet_data["sma_rssi"]
                    ])
                    file.flush()  # Ensure data is written to disk
                    packet_data = {}  # Clear dictionary for next packet

        except KeyboardInterrupt:
            print("\nKeyboard interrupt detected! Closing serial connection...")
            ser.close()
            sys.exit(0)


if __name__ == "__main__":
    main()