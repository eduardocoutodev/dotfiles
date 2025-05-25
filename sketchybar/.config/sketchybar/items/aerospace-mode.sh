#!/usr/bin/env sh

sketchybar --add event aerospace_mode_update

# Create the mode indicator with modern styling
sketchybar --add item aerospace.mode left \
           --set aerospace.mode \
                 update_freq=1 \
                 icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
                 icon.color=0xffffffff \
                 icon.padding_left=8 \
                 icon.padding_right=6 \
                 label.font="JetBrainsMono Nerd Font:Medium:11.0" \
                 label.color=0xffffffff \
                 label.padding_right=8 \
                 label.drawing=off \
                 background.color=0x20ffffff \
                 background.corner_radius=10 \
                 background.height=22 \
                 background.border_width=1 \
                 background.border_color=0x30ffffff \
                 background.padding_left=4 \
                 background.padding_right=4 \
                 popup.background.color=0x90000000 \
                popup.background.border_color=0x50ffffff \
                 popup.background.corner_radius=8 \
                 popup.background.border_width=1 \
                 script="$PLUGIN_DIR/aerospace_mode.sh" \
                 click_script="$PLUGIN_DIR/aerospace_mode_popup.sh" \
           --subscribe aerospace.mode aerospace_mode_update

# Create popup menu items
sketchybar --add item mode.main popup.aerospace.mode \
           --set mode.main icon="󰧨" \
                          icon.font="JetBrainsMono Nerd Font:Medium:13.0" \
                          icon.color=0xff8aadf4 \
                          icon.padding_left=8 \
                          icon.padding_right=6 \
                          label="Main Mode" \
                          label.font="JetBrainsMono Nerd Font:Medium:12.0" \
                          label.color=0xffffffff \
                          label.padding_right=12 \
                          background.color=0x00ffffff \
                          background.corner_radius=6 \
                          background.height=26 \
                          background.padding_left=4 \
                          background.padding_right=4 \
                          click_script="aerospace mode main; sketchybar --set aerospace.mode popup.drawing=off"

sketchybar --add item mode.passthrough popup.aerospace.mode \
           --set mode.passthrough icon="󰌾" \
                                 icon.font="JetBrainsMono Nerd Font:Medium:13.0" \
                                 icon.color=0xffeed49f \
                                 icon.padding_left=8 \
                                 icon.padding_right=6 \
                                 label="Passthrough" \
                                 label.font="JetBrainsMono Nerd Font:Medium:12.0" \
                                 label.color=0xffffffff \
                                 label.padding_right=12 \
                                 background.color=0x00ffffff \
                                 background.corner_radius=6 \
                                 background.height=26 \
                                 background.padding_left=4 \
                                 background.padding_right=4 \
                                 click_script="aerospace mode passthrough; sketchybar --set aerospace.mode popup.drawing=off"

sketchybar --add item mode.resize popup.aerospace.mode \
           --set mode.resize icon="󰩨" \
                            icon.font="JetBrainsMono Nerd Font:Medium:13.0" \
                            icon.color=0xffa6da95 \
                            icon.padding_left=8 \
                            icon.padding_right=6 \
                            label="Resize Mode" \
                            label.font="JetBrainsMono Nerd Font:Medium:12.0" \
                            label.color=0xffffffff \
                            label.padding_right=12 \
                            background.color=0x00ffffff \
                            background.corner_radius=6 \
                            background.height=26 \
                            background.padding_left=4 \
                            background.padding_right=4 \
                            click_script="aerospace mode resize; sketchybar --set aerospace.mode popup.drawing=off"
