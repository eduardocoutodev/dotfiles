#!/bin/bash

CURRENT_MODE=$(aerospace list-modes --current 2>/dev/null || echo "main")

# Modern color palette
MAIN_COLOR=0xff8aadf4
PASSTHROUGH_COLOR=0xffeed49f
RESIZE_COLOR=0xffa6da95
UNKNOWN_COLOR=0xffed8796

case "$CURRENT_MODE" in
    "main")
        # Main mode - normal operation
        sketchybar --set aerospace.mode \
                         icon="󰧨" \
                         icon.color=$MAIN_COLOR \
                         background.color=0x20$8aadf4 \
                         background.border_color=$MAIN_COLOR \
                         label="" \
                         label.drawing=off
        echo "Set to MAIN mode"
        ;;
    "passthrough")
        # Passthrough mode - aerospace disabled
        sketchybar --set aerospace.mode \
                         icon="󰌾" \
                         icon.color=$PASSTHROUGH_COLOR \
                         background.color=0x20$eed49f \
                         background.border_color=$PASSTHROUGH_COLOR \
                         label="PASS" \
                         label.drawing=on
        echo "Set to PASSTHROUGH mode"
        ;;
    "resize")
        # Resize mode - window manipulation
        sketchybar --set aerospace.mode \
                         icon="󰩨" \
                         icon.color=$RESIZE_COLOR \
                         background.color=0x20$a6da95 \
                         background.border_color=$RESIZE_COLOR \
                         label="SIZE" \
                         label.drawing=on
        echo "Set to RESIZE mode"
        ;;
    *)
        # Unknown or error state
        sketchybar --set aerospace.mode \
                         icon="󰀧" \
                         icon.color=$UNKNOWN_COLOR \
                         background.color=0x20$ed8796 \
                         background.border_color=$UNKNOWN_COLOR \
                         label="???" \
                         label.drawing=on
        echo "Unknown mode: $CURRENT_MODE"
        ;;
esac