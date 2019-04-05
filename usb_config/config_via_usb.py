#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import time
if sys.version_info[0] < 3:
    print("This script assumes Python 3. Exiting.")
    sys.exit(-1)
import serial

USBPORT = '/dev/ttyUSB0'


def write_command(port_string, text):
    ser = serial.Serial()
    ser.baudrate = 9600
    ser.port = port_string
    ser.open()
    values = bytearray(text.encode('utf-8'))
    ser.write(values)
    time.sleep(1)
    ser.close()


def print_manual():
    print("Usage: config_via_usb.py <SSID> <PASSWORD> <CHANNELKEY> [STATESERVER] [PORT]")
    print("\tThis will send given configuration to BI-Beacon connected to")
    print("\t%s and then reboot it." % USBPORT)
    print("\tThe STATESERVER and PORT parameters will default to api.cilamp.se and 4040")
    print("\tif not specified.")


def print_outtro():
    print("BI-Beacon configured and rebooting. If not green within 30 seconds,")
    print("check WiFi credentials - it is case sensitive and whitespace is")
    print("not supported.")


def configure_via_usb(ssid, password, channelkey, stateserver, port):
    command = 'config %s %s %s %s %s\r' % (ssid, password, channelkey, stateserver, port)
    print("Sending command: " + command)
    for i in range(100):
        port = 'COM' + str(i) + ':'
        try:
            write_command(port, command)
            print("Writing to " + port)
        except serial.serialutil.SerialException:
            pass


def run(params):
    stateserver = 'api.cilamp.se'
    port = 4040
    num_params = len(params)

    if num_params == 3:
        (ssid, password, channelkey) = params
    elif num_params == 5:
        (ssid, password, channelkey, stateserver, port) = params
    else:
        print_manual()
        return

    configure_via_usb(ssid, password, channelkey, stateserver, port)
    print_outtro()


if __name__ == '__main__':
    run(sys.argv[1:])
