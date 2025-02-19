#!/usr/bin/env sh

sketchybar --add item battery right \
           --set battery update_freq=120 \
           --set battery script="$PLUGIN_DIR/battery.sh" \
           --set battery background.padding_left=10 \
           --set battery background.padding_right=10 \ 
           --subscribe battery power_source_change \
           --subscribe battery system_woke \