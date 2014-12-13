from time import sleep
import serial

#this example sends a "5" to the USB port

ser = serial.Serial('/dev/tty.usbserial-A9KFR1HL', 9600) # Establish the connection on a specific ports(1);
print ser.readline() # Read the newest output from the Arduino
sleep(1)
ser.write(str("5")) # Convert the decimal number to ASCII then send it to the Arduino
print ser.readline() # Read the newest output from the Arduino
