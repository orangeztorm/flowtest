#!/bin/bash
set -e

# FlowTest SDK CI Integration Test Script
# Runs integration tests with proper device detection and artifact collection

echo "🚀 Starting FlowTest SDK Integration Tests"

# Function to detect available devices
detect_device() {
    echo "📱 Detecting available devices..."
    
    # Check for iOS simulators
    IOS_DEVICE=$(flutter devices --machine | jq -r '.[] | select(.category == "mobile" and .platformType == "ios") | .id' | head -n1)
    
    # Check for Android emulators  
    ANDROID_DEVICE=$(flutter devices --machine | jq -r '.[] | select(.category == "mobile" and .platformType == "android") | .id' | head -n1)
    
    # Check for desktop platforms
    MACOS_DEVICE=$(flutter devices --machine | jq -r '.[] | select(.category == "desktop" and .platformType == "darwin") | .id' | head -n1)
    
    # Priority: iOS > Android > macOS
    if [ "$IOS_DEVICE" != "null" ] && [ -n "$IOS_DEVICE" ]; then
        echo "✅ Using iOS Simulator: $IOS_DEVICE"
        echo "$IOS_DEVICE"
    elif [ "$ANDROID_DEVICE" != "null" ] && [ -n "$ANDROID_DEVICE" ]; then
        echo "✅ Using Android Emulator: $ANDROID_DEVICE"
        echo "$ANDROID_DEVICE"
    elif [ "$MACOS_DEVICE" != "null" ] && [ -n "$MACOS_DEVICE" ]; then
        echo "✅ Using macOS Desktop: $MACOS_DEVICE"
        echo "$MACOS_DEVICE"
    else
        echo "❌ No suitable devices found for integration testing"
        return 1
    fi
}

# Function to prepare test environment
prepare_environment() {
    echo "🔧 Preparing test environment..."
    
    # Clean previous builds
    flutter clean
    
    # Get dependencies
    flutter pub get
    
    # Verify no compilation errors
    flutter analyze --fatal-infos
    
    # Create screenshots directory
    mkdir -p flowtest_screenshots
    
    echo "✅ Environment prepared"
}

# Function to run integration tests
run_integration_tests() {
    local device_id=$1
    echo "🧪 Running integration tests on device: $device_id"
    
    # Set test timeout
    export FLUTTER_TEST_TIMEOUT=600  # 10 minutes
    
    # Run integration tests with verbose output
    if flutter test integration_test/ \
        --device-id="$device_id" \
        --tags integration \
        --verbose \
        --reporter=github \
        --coverage; then
        echo "✅ Integration tests passed!"
        return 0
    else
        echo "❌ Integration tests failed!"
        return 1
    fi
}

# Function to collect test artifacts
collect_artifacts() {
    echo "📦 Collecting test artifacts..."
    
    # Create artifacts directory
    mkdir -p test_artifacts
    
    # Copy screenshots if they exist
    if [ -d "flowtest_screenshots" ] && [ "$(ls -A flowtest_screenshots)" ]; then
        cp -r flowtest_screenshots test_artifacts/
        echo "📸 Screenshots collected: $(ls flowtest_screenshots | wc -l) files"
    fi
    
    # Copy coverage if it exists
    if [ -f "coverage/lcov.info" ]; then
        cp -r coverage test_artifacts/
        echo "📊 Coverage report collected"
    fi
    
    # Copy test logs
    if [ -f "flutter_test.log" ]; then
        cp flutter_test.log test_artifacts/
        echo "📝 Test logs collected"
    fi
    
    echo "✅ Artifacts ready in test_artifacts/"
}

# Function to upload artifacts (for CI environments)
upload_artifacts() {
    if [ "$CI" = "true" ]; then
        echo "☁️ Uploading artifacts to CI system..."
        
        # GitHub Actions
        if [ -n "$GITHUB_ACTIONS" ]; then
            echo "::set-output name=artifacts-path::test_artifacts"
        fi
        
        # Add other CI system integrations here
        # CircleCI, GitLab CI, etc.
    fi
}

# Main execution
main() {
    echo "🏁 FlowTest SDK CI Pipeline Started"
    
    # Change to script directory
    cd "$(dirname "$0")"
    
    # Prepare environment
    prepare_environment
    
    # Detect device
    DEVICE_ID=$(detect_device)
    if [ $? -ne 0 ]; then
        echo "❌ CI Pipeline Failed: No devices available"
        exit 1
    fi
    
    # Run tests
    if run_integration_tests "$DEVICE_ID"; then
        echo "✅ All tests passed!"
        TEST_RESULT=0
    else
        echo "❌ Tests failed!"
        TEST_RESULT=1
    fi
    
    # Always collect artifacts
    collect_artifacts
    upload_artifacts
    
    echo "🏁 FlowTest SDK CI Pipeline Completed"
    exit $TEST_RESULT
}

# Handle command line arguments
case "${1:-}" in
    "--device-id")
        if [ -n "$2" ]; then
            echo "🎯 Using specified device: $2"
            prepare_environment
            run_integration_tests "$2"
            collect_artifacts
        else
            echo "❌ Device ID required after --device-id"
            exit 1
        fi
        ;;
    "--help")
        echo "FlowTest SDK CI Integration Test Script"
        echo ""
        echo "Usage:"
        echo "  $0                    # Auto-detect device and run tests"
        echo "  $0 --device-id <id>   # Use specific device"
        echo "  $0 --help             # Show this help"
        echo ""
        echo "Environment Variables:"
        echo "  CI=true               # Enable CI mode"
        echo "  FLUTTER_TEST_TIMEOUT  # Test timeout in seconds (default: 600)"
        ;;
    *)
        main
        ;;
esac
