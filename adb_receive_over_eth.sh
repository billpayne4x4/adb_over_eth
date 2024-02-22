#!/bin/bash

# Name of your AVD
AVD_NAME="Pixel_3a_API_34_extension_level_7_x86_64"

# Path to Android SDK
ANDROID_SDK_PATH=~/Android/Sdk

# Check if the emulator is already running
EMULATOR_RUNNING=$(adb devices | grep emulator | cut -f 1)

if [ -z "$EMULATOR_RUNNING" ]; then
    echo "Emulator is not running. Starting emulator..."
    # Start the emulator in the background
    $ANDROID_SDK_PATH/emulator/emulator -avd "$AVD_NAME" &
    # Wait for the emulator to become ready
    $ANDROID_SDK_PATH/platform-tools/adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'
    echo "Emulator is ready."
else
    echo "Emulator is already running."
fi

# It's a good idea to wait a bit after the emulator starts or is detected as running
# before trying to switch ADB to TCP/IP mode, to ensure the device is fully booted and ADB is ready.
sleep 5

# Enable ADB over TCP/IP on port 5555
$ANDROID_SDK_PATH/platform-tools/adb tcpip 5555

echo "ADB is set to listen on TCP/IP mode. You can now connect over the network for debugging."
