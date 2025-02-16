#!/usr/bin/env sh

sketchybar --add item volume right \
           --set volume \
             icon=􀊧 \
             icon.font="$FONT:Regular:14.0" \
             icon.color=$WHITE \
             label.drawing=yes \
             label.color=$WHITE \
             script="$PLUGIN_DIR/volume.sh" \
             update_freq=5 \
             click_script="$PLUGIN_DIR/volume.sh click" \
           --subscribe volume volume_change