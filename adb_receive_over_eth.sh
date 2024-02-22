#!/bin/bash

# Name of your AVD
AVD_NAME="Pixel_3a_API_34_extension_level_7_x86_64"

# Path to Android SDK
ANDROID_SDK_PATH=~/Android/Sdk

# Ports configuration
ADB_PORT=5555 # Port for ADB
LISTEN_PORT=5556 # Port for socat to listen on and forward to ADB_PORT

# Get the first IP address of this machine
MYIP=$(hostname -I | awk '{print $1}')

# Function to check if emulator is ready
wait_for_emulator() {
    until $ANDROID_SDK_PATH/platform-tools/adb shell 'getprop sys.boot_completed' | grep -m 1 '1'; do
        echo "Waiting for device to complete boot..."
        sleep 1
    done
}

# Function for cleanup
cleanup() {
    echo "\nCleaning up..."

    # Kill socat process if it's running. No need to check SOCAT_PID because of trap
    kill $SOCAT_PID 2>/dev/null

    # Stop the emulator
    if [ ! -z "$EMULATOR_PID" ]; then
        kill $EMULATOR_PID
        echo "Emulator stopped."
    fi

    # Kill all adb processes
    $ANDROID_SDK_PATH/platform-tools/adb kill-server
    echo "ADB server stopped."

    echo "Cleanup completed."
    exit 0 # Ensure script exits cleanly
}

# Trap Ctrl+C and execute cleanup function
trap cleanup INT

# Check if the emulator is already running
EMULATOR_RUNNING=$($ANDROID_SDK_PATH/platform-tools/adb devices | grep $ANDROID_SDK_PATH/emulator/emulator | cut -f 1)

if [ -z "$EMULATOR_RUNNING" ]; then
    echo "Emulator is not running. Starting emulator and waiting for it to boot..."
    # Start the emulator in the background, redirecting stdout and stderr to /dev/null
    $ANDROID_SDK_PATH/emulator/emulator -avd "$AVD_NAME" -no-snapshot-load > /dev/null 2>&1 &
    EMULATOR_PID=$!
    
    wait_for_emulator
    
    echo "Emulator is ready."
else
    echo "Emulator is already running."
fi

# Enable ADB over TCP/IP on the specified port
$ANDROID_SDK_PATH/platform-tools/adb tcpip $ADB_PORT

echo "ADB is set to listen on TCP/IP mode on port $ADB_PORT. You can now connect over the network for debugging."
echo "In the ADB terminal in Visual Studio: adb connect $MYIP:$LISTEN_PORT"

# Check if LISTEN_PORT is in use
if lsof -i :$LISTEN_PORT | grep LISTEN; then
    echo "Port $LISTEN_PORT is already in use. Please close the process or choose a different port."
    exit 1
fi

# Forward the ADB port using socat
socat TCP-LISTEN:$LISTEN_PORT,fork,reuseaddr,sndbuf=131072,rcvbuf=131072 TCP:127.0.0.1:$ADB_PORT

# Wait for user to request cleanup
read -p "Press any key to stop the emulator and clean up... " -n1 -s
cleanup
