# Define the IP address of the Android device or emulator
$deviceIP = "192.168.123.123"

# Define the port number, default is 5555 for ADB over TCP/IP
$port = "5555"

# Combine IP and port to form the address
$address = $deviceIP + ":" + $port

# Locate ADB
# Update this path to the actual location of your adb.exe if different
$adbPath = "C:\Program Files (x86)\Android\android-sdk\platform-tools\adb.exe"

# Start ADB server to ensure it's running
Start-Process -FilePath $adbPath -ArgumentList "start-server" -NoNewWindow -Wait

# Connect to the device
Start-Process -FilePath $adbPath -ArgumentList "connect", $address -NoNewWindow -Wait

# Optional: Verify connection by listing connected devices
Start-Process -FilePath $adbPath -ArgumentList "devices" -NoNewWindow -Wait
