# Arduino Servo Control

An Arduino project demonstrating servo motor control with two implementations: a simple Arduino C++ sketch using the Servo library and an advanced AVR assembly version with multi-LED position feedback for the Arduino Mega 2560.

![Arduino](https://img.shields.io/badge/Platform-Arduino-00979D?style=flat-square&logo=arduino&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

## Overview

This project provides two approaches to controlling an SG90 servo motor:

1. **Arduino Sketch** (`Blinking.ino`) — High-level implementation using the Arduino Servo library. Ideal for beginners and quick prototyping.

2. **AVR Assembly** (`Blinking.S`) — Low-level implementation that drives the servo via direct PWM and includes RGB LED indicators that light up based on the servo's angular position. Suitable for embedded systems learning and performance-critical applications.

## Hardware Requirements

### Arduino Sketch (Blinking.ino)
| Component | Specification |
|-----------|---------------|
| Board | Arduino Uno / Mega 2560 / compatible |
| Servo | SG90 or similar 5V hobby servo |
| Connection | Servo signal → Digital Pin 10 |

### Assembly Version (Blinking.S)
| Component | Specification |
|-----------|---------------|
| Board | **Arduino Mega 2560** |
| Servo | SG90 hobby servo |
| LEDs | Red, Green, Blue (with appropriate current-limiting resistors, ~220Ω) |

### Wiring (Assembly Version)

| Pin | Function |
|-----|----------|
| D10 (PB6) | Servo PWM signal |
| D30 (PC7) | Red LED |
| D31 (PC6) | Green LED |
| D32 (PC5) | Blue LED |

## Getting Started

### Prerequisites
- [Arduino IDE](https://www.arduino.cc/en/software) (1.8.x or 2.x)
- For assembly: [avr-gcc](https://gcc.gnu.org/wiki/avr-gcc) toolchain (included with Arduino IDE)

### Arduino Sketch
1. Clone or download this repository.
2. Open `Blinking.ino` in the Arduino IDE.
3. Select your board under **Tools → Board**.
4. Connect the servo signal wire to **Pin 10**.
5. Upload the sketch.

The servo will cycle through 0°, 45°, and 90° with 1-second pauses between each position.

### Assembly Version
The `Blinking.S` file is an AVR assembly program targeting the Arduino Mega 2560. It requires assembly and upload via the avr-gcc toolchain. The servo moves through 0°, 180°, and 90° while lighting the Red, Green, and Blue LEDs at corresponding positions.

## Project Structure

```
Blinking/
├── Blinking.ino    # Arduino sketch (Servo library)
├── Blinking.S      # AVR assembly implementation with LEDs
├── Blink.txt       # Legacy notes
└── README.md       # This file
```

## How It Works

### Arduino Sketch
The sketch uses the built-in `Servo.h` library:
- Attaches the servo to pin 10
- Loops through `write(0)`, `write(45)`, and `write(90)`
- Uses 1-second delays between positions

### Assembly Version
- Generates PWM pulses manually for the servo on PB6
- Uses a lookup table for servo angles (0°, 180°, 90°)
- Drives three LEDs based on position index to provide visual feedback
- Implements proper servo timing (20 ms frame, variable pulse width)

## License

This project is open source. Feel free to use and modify it for your own projects.

## Contributing

Contributions are welcome. Please feel free to submit issues and pull requests.
