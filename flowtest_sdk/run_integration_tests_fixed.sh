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

# Check for connected devices or emulators (improved regex for all SDK channels)
DEVICES_JSON=$(flutter devices --machine 2>/dev/null || echo "[]")

if echo "$DEVICES_JSON" | grep -Eq '"emulator":true|"ephemeral":|"type":"device"'; then
    if echo "$DEVICES_JSON" | grep -q '"emulator":true'; then
        echo "✅ Emulator detected"
    elif echo "$DEVICES_JSON" | grep -q '"ephemeral":'; then
        echo "✅ Emulator detected (ephemeral)"
    else
        echo "✅ Physical device detected"
    fi
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
            
            # Wait for emulator to boot (max 2 minutes) with timeout fallback
            echo "⏳ Waiting for emulator to boot..."
            
            # Handle different timeout command availability
            if command -v timeout >/dev/null 2>&1; then
                TIMEOUT_CMD="timeout 120"
            elif command -v gtimeout >/dev/null 2>&1; then
                TIMEOUT_CMD="gtimeout 120"
            else
                echo "⚠️ No timeout command available, using basic wait..."
                TIMEOUT_CMD=""
            fi
            
            if [ -n "$TIMEOUT_CMD" ]; then
                $TIMEOUT_CMD bash -c 'until flutter devices --machine | grep -Eq "emulator|ephemeral"; do sleep 2; done'
            else
                # Basic wait without timeout (fallback)
                for i in {1..60}; do
                    if flutter devices --machine | grep -Eq "emulator|ephemeral"; then
                        break
                    fi
                    sleep 2
                done
            fi
            
            if flutter devices --machine | grep -Eq "emulator|ephemeral"; then
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

# Exit early if no devices available (change to exit 1 if you want CI to fail)
if [ "$DEVICE_AVAILABLE" = false ]; then
    echo "🚫 No emulator or physical device detected — skipping integration tests."
    echo "💡 To run integration tests:"
    echo "   • Connect a physical device, or"
    echo "   • Start an emulator, or"
    echo "   • Set AUTO_START_EMULATOR=true for CI environments"
    exit 0  # Change to exit 1 if you want CI to fail when no device
fi

# Show connected devices
echo "📱 Available devices:"
flutter devices

# Run the integration tests with proper tagging
echo "🧪 Running Flutter integration tests..."

if [ -d "integration_test" ]; then
    echo "Running integration_test/ directory..."
    flutter test integration_test --tags integration
elif [ -d "test/integration" ]; then
    echo "Running test/integration/ directory..."
    flutter test test/integration --tags integration
else
    echo "❌ No integration test directory found (integration_test/ or test/integration/)"
    exit 1
fi

echo "✅ All integration tests completed successfully!"
