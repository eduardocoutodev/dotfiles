#!/usr/bin/env sh

sketchybar --add event aerospace_mode_update

sketchybar --add item aerospace.mode left \
           --set aerospace.mode \
           update_freq=0.5 \
           icon.drawing=off \
           background.drawing=on \
           background.height=24 \
           background.corner_radius=8 \
           script="$PLUGIN_DIR/aerospace_mode.sh" \
           --subscribe aerospace.mode aerospace_mode_update