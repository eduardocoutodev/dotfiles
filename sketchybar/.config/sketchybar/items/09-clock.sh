#!/usr/bin/env sh

sketchybar --add item clock right \
           --set clock update_freq=10 \
           --set clock script="$PLUGIN_DIR/clock.sh" \
           --set clock background.padding_left=10 \
           --set clock background.padding_right=10