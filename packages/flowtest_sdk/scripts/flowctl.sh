#!/bin/bash

# FlowTest CLI - Run flows from terminal
# Usage: ./flowctl.sh <flow_file.json> [speed]

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <flow_file.json> [speed]"
    echo "  flow_file.json: Path to the flow JSON file"
    echo "  speed: Optional playback speed (default: 1.0)"
    exit 1
fi

FLOW_FILE="$1"
SPEED="${2:-1.0}"

# Check if flow file exists
if [ ! -f "$FLOW_FILE" ]; then
    echo "Error: Flow file '$FLOW_FILE' not found"
    exit 1
fi

# Base64 encode the flow JSON
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    B64=$(base64 -i "$FLOW_FILE")
else
    # Linux
    B64=$(base64 -w0 "$FLOW_FILE")
fi

echo "Running flow: $(basename "$FLOW_FILE") at ${SPEED}x speed"
echo "Flow will start automatically when app launches..."

# Run the app with the encoded flow
flutter run \
    --dart-define=FLOW_REPLAY_JSON_B64="$B64" \
    --dart-define=FLOW_REPLAY_SPEED="$SPEED"
