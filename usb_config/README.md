Usage
*****

    python config_via_usb.py <SSID> <PASSWORD> <CHANNELKEY> [STATESERVER] [PORT]

This will send given configuration to BI-Beacon connected to /dev/ttyUSB0 and then
reboot it. The STATESERVER and PORT parameters will default to api.cilamp.se and 4040 if not specified.
