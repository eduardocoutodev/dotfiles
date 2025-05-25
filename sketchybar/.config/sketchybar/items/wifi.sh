#!/usr/bin/env sh

sketchybar --add item wifi right \
           --set wifi icon="󰤨" \
                      icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
                      icon.color=0xffffffff \
                      icon.padding_left=8 \
                      icon.padding_right=6 \
                      label="↓ 0 ↑ 0" \
                      label.font="JetBrainsMono Nerd Font:Medium:11.0" \
                      label.color=0x80ffffff \
                      label.padding_right=8 \
                      update_freq=2 \
                      script="$PLUGIN_DIR/wifi.sh"