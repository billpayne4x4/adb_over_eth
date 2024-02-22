#!/bin/bash

# Name of your AVD
AVD_NAME="Pixel_3a_API_34_extension_level_7_x86_64"

# Start the emulator in the background
~/Android/Sdk/emulator/emulator -avd "$AVD_NAME" &

# Wait for the emulator to become ready
~/Android/Sdk/platform-tools/adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'

echo "Emulator is ready."

# Enable ADB over TCP/IP on port 5555
~/Android/Sdk/platform-tools/adb tcpip 5555

echo "You can now start debugging with Visual Studio/VS Code."
