#!/bin/bash

# Professional CI/CD script for running Flutter integration tests
# This is Layer 2 of our defense-in-depth strategy

set -e  # Exit on any error

echo "🔍 Checking Flutter environment for integration test capability..."

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found in PATH"
    exit 1
fi

# Check for connected devices or emulators
DEVICES_JSON=$(flutter devices --machine 2>/dev/null || echo "[]")

if echo "$DEVICES_JSON" | grep -q '"ephemeral":'; then
    echo "✅ Emulator detected"
    DEVICE_AVAILABLE=true
elif echo "$DEVICES_JSON" | grep -q '"type":"device"'; then
    echo "✅ Physical device detected"
    DEVICE_AVAILABLE=true
else
    echo "🚫 No emulator or physical device detected"
    DEVICE_AVAILABLE=false
fi

# Option to auto-start emulator (for CI environments)
if [ "$DEVICE_AVAILABLE" = false ] && [ "${AUTO_START_EMULATOR:-false}" = "true" ]; then
    echo "🚀 Attempting to start emulator..."
    
    # Check if Android SDK is available
    if command -v emulator &> /dev/null; then
        # List available AVDs
        AVDS=$(emulator -list-avds 2>/dev/null | head -1)
        
        if [ -n "$AVDS" ]; then
            echo "📱 Starting emulator: $AVDS"
            emulator -avd "$AVDS" -no-window -no-audio -no-boot-anim &
            EMULATOR_PID=$!
            
            # Wait for emulator to boot (max 2 minutes)
            echo "⏳ Waiting for emulator to boot..."
            timeout 120 bash -c 'until flutter devices --machine | grep -q "ephemeral"; do sleep 2; done'
            
            if flutter devices --machine | grep -q "ephemeral"; then
                echo "✅ Emulator started successfully"
                DEVICE_AVAILABLE=true
                
                # Cleanup function to kill emulator on exit
                trap "echo '🛑 Shutting down emulator...'; kill $EMULATOR_PID 2>/dev/null || true" EXIT
            else
                echo "❌ Emulator failed to start within timeout"
                kill $EMULATOR_PID 2>/dev/null || true
            fi
        else
            echo "❌ No Android Virtual Devices (AVDs) found"
        fi
    else
        echo "❌ Android emulator not found in PATH"
    fi
fi

# Exit early if no devices available
if [ "$DEVICE_AVAILABLE" = false ]; then
    echo "🚫 No emulator or physical device detected — skipping integration tests."
    echo "💡 To run integration tests:"
    echo "   • Connect a physical device, or"
    echo "   • Start an emulator, or"
    echo "   • Set AUTO_START_EMULATOR=true for CI environments"
    exit 0
fi

# Show connected devices
echo "📱 Available devices:"
flutter devices

# Run the integration tests
echo "🧪 Running Flutter integration tests..."

if [ -d "integration_test" ]; then
    echo "Running integration_test/ directory..."
    flutter test integration_test
elif [ -d "test/integration" ]; then
    echo "Running test/integration/ directory..."
    flutter test test/integration
else
    echo "❌ No integration test directory found (integration_test/ or test/integration/)"
    exit 1
fi

echo "✅ All integration tests completed successfully!"
