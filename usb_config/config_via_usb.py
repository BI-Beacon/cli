
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import serial
import sys
if sys.version_info[0] < 3:
    print("This script assumes Python 3. Exiting.")
    sys.exit(-1)
import serial

PORT = '/dev/ttyUSB0'


def write_command(port_string, text):
    ser = serial.Serial()
    ser.baudrate = 9600
    ser.port = port_string
    ser.open()
    values = bytearray(text.encode('utf-8'))
    ser.write(values)
    ser.close()


def print_manual():
    print("Usage: config_via_usb.py <SSID> <PASSWORD> <SYSTEMID>")
    print("This will send configuration specified at command line")
    print("to BI-Beacon connected to port %s." % PORT)
    print("This will save credentials SSID+PASSWORD and systemid")
    print("on the device and reboot it.")


def print_outtro():
    print("BI-Beacon configured and rebooting. If not green within 30 seconds,")
    print("check WiFi credentials - it is case sensitive and whitespace is")
    print("not supported.")


def configure_via_usb(ssid, password, systemid):
    command = 'config %s %s %s\n' % (ssid, password, systemid)
    print("Sending command: " + command)
    write_command(PORT, command)


if __name__ == '__main__':
    if len(sys.argv) == 4:
        (ssid, password, systemid) = sys.argv[1:]
        configure_via_usb(ssid, password, systemid)
        print_outtro()
    else:
        print_manual()
