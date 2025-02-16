#!/bin/bash

echo "Event received $EVENT WITH $CURRENT_MODE" >> /tmp/sketchybar_debug.log
echo "Script triggered at $(date)" >> /tmp/sketchybar_debug.log

# Get the current mode from environment variable
if [ -f /tmp/aerospace_current_mode ]; then
    CURRENT_MODE=$(cat /tmp/aerospace_current_mode)
else
    CURRENT_MODE="MAIN"
fi

# Debug logging
echo "Current Mode: $CURRENT_MODE" >> /tmp/sketchybar_debug.log

# Set colors based on mode
case $CURRENT_MODE in
    "MAIN")
        COLOR=0xff50fa7b
        ;;
    "RESIZE")
        COLOR=0xff8be9fd
        ;;
    "PASSTHROUGH")
        COLOR=0xffA020F0
        ;;
    *)
        COLOR=0xff50fa7b
        CURRENT_MODE="MAIN"
        ;;
esac

# Update sketchybar
sketchybar --set aerospace.mode \
           label="$CURRENT_MODE" \
           background.color=$COLOR \
           label.padding_left=10 \
           label.padding_right=10

# More debug logging
echo "Updated sketchybar with mode: $CURRENT_MODE and color: $COLOR" >> /tmp/sketchybar_debug.log