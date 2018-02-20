# ScreenLED
A simple macOS application that displays dominant screen colors on LED strips with Arduino

Demo:

![Gif demo](https://ekedaniel.hu/static/img/led.cb70db7.gif)

Steps to use:
- Get an individually addressable RGB LED strip and an Arduino. With referably min. 27 LED.
- Attach the LED strip behind your TV / Monitor
- Connect the LEDs to GND, 5V and port 6 of Arduino
- Connect Arduino to the Mac, check the port of the device with the Arduino IDE (eg./dev/cu.usbmodem1441)
- Replace the port number in the macOS project
- Run the project and enjoy!

External sources used:
- https://github.com/buranmert/ColorFinder
- https://github.com/armadsen/ORSSerialPort
