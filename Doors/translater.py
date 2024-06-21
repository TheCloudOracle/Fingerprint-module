#!/usr/bin/env python3

import serial
import time


def main():
    try:
        with open('access.txt', 'r') as file:
            content = file.read().strip()
    except FileNotFoundError:
        print("access.txt not found.")
        return b'File not found'

    arduino = serial.Serial(port='/dev/ttyACM0', baudrate=9600, timeout=0.1)
    
    if content == 'Access Granted.':
        arduino.write(bytes('Access Granted', 'utf-8'))
    else:
        arduino.write(bytes('Access Denied', 'utf-8'))

    time.sleep(0.05)
    data = arduino.readline()
    arduino.close()  
    return data


if __name__ == '__main__':
    #time.sleep(3)
    value = main()
    print(value)
