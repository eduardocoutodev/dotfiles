#!/usr/bin/env sh

sketchybar --add item calendar right \
           --set calendar icon="􀧞" \
                         icon.font="JetBrainsMono Nerd Font:Medium:14.0" \
                         icon.color=0xffffffff \
                         icon.padding_left=8 \
                         icon.padding_right=6 \
                         label.font="JetBrainsMono Nerd Font:Medium:12.0" \
                         label.color=0xffffffff \
                         label.padding_right=8 \
                         background.color=0x20ffffff \
                         background.corner_radius=10 \
                         background.height=22 \
                         background.border_width=1 \
                         background.border_color=0x30ffffff \
                         background.padding_left=4 \
                         background.padding_right=4 \
                         update_freq=30 \
                         script="$PLUGIN_DIR/clock.sh" \
                         click_script="open -a Calendar"