#!/bin/bash

CURRENT_MODE=$(aerospace list-modes --current)

# Debug logging
echo "Current Mode: $CURRENT_MODE" >> /tmp/sketchybar_debug.log

# Set colors based on mode
case $CURRENT_MODE in
    "main")
        COLOR=0xff9370DB  # Purple (Medium Purple)
        CURRENT_MODE="MAIN"
    ;;
    "resize")
        COLOR=0xff4169E1  # Blue (Royal Blue)
        CURRENT_MODE="RESIZE"
    ;;
    "passthrough")
        COLOR=0xffFFA500  # Orange
        CURRENT_MODE="PASSTHROUGH"
    ;;
    *)
        COLOR=0xff9370DB  # Purple (Medium Purple) for default
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