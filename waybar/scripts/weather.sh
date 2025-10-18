#!/bin/bash

# Get weather from wttr.in (no API key needed)
# You can change the location if needed
LOCATION="auto"

WEATHER=$(curl -s "https://wttr.in/${LOCATION}?format=%c+%t" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$WEATHER" ]; then
    echo '{"text": "Weather: N/A", "tooltip": "Failed to fetch weather"}'
    exit 0
fi

# Get more detailed info for tooltip
WEATHER_DETAILED=$(curl -s "https://wttr.in/${LOCATION}?format=%c+%t+%C+%w+%h" 2>/dev/null)

echo "{\"text\": \"${WEATHER}\", \"tooltip\": \"${WEATHER_DETAILED}\"}"
