# Bluetooth App

## Introduction

**Bluetooth App** is a Flutter application designed to connect with and manage Bluetooth devices. It utilizes the Flutter framework and the `flutter_blue` package to scan for devices, connect with them, and handle data transfer between the app and the devices.

This project aims to provide a user-friendly interface for managing Bluetooth connections, including capabilities for device discovery, connection management, and displaying device-specific data such as temperature and humidity readings from connected sensors.

## Features

- **Device Scanning**: Scan for nearby Bluetooth devices.
- **Device Connection**: Connect to and disconnect from devices.
- **Data Display**: Show real-time data from connected devices, such as temperature and humidity.
- **UI Enhancements**: A modern UI that enhances user experience through animations and responsive design.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What you need to install the software:

- [Flutter](https://flutter.dev/docs/get-started/install)
- Compatible IDE (e.g., Android Studio, VSCode)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/bluetooth_app.git

2. **Navigate to the project directory**
   ```bash
   cd bluetooth_app

3. **Install dependencies**
     ```bash
   flutter pub get

4. **Run the Bluetooth_app a device or start an emulator, then execute:**
     ```bash
   flutter run

## Usage

### Scanning for Devices

1. Open the app.
2. Navigate to the 'Scan' tab.
3. Press 'Start Scanning' to discover nearby Bluetooth devices.

### Connecting to a Device

1. From the list of scanned devices, tap on a device to connect.
2. View the device information and available services on the device detail page.

### Viewing Data

1. Once connected to a device, subscribe to available characteristics to start receiving data.
2. Data such as temperature or humidity will be displayed on the UI.

## Architecture

Here's a brief description of the project's architecture:

- **lib/**: Contains the Dart code for the application.
  - **main.dart**: The entry point of the application.
  - **bluetooth_manager.dart**: Manages Bluetooth operations.
  - **ui/**: UI components of the application.
- **assets/**: Images and other assets used in the application.

