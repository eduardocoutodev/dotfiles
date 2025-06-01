#!/usr/bin/env sh

sketchybar --add item pomodoro center \
           --set pomodoro icon="󰔟" \
                         icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
                         icon.color=0xff8aadf4 \
                         icon.padding_left=8 \
                         icon.padding_right=6 \
                         label="25:00" \
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
                         popup.background.color=0x90000000 \
                         popup.background.corner_radius=12 \
                         popup.background.border_width=1 \
                         popup.background.border_color=0x50ffffff \
                         popup.background.padding_left=12 \
                         popup.background.padding_right=12 \
                         update_freq=1 \
                         script="$PLUGIN_DIR/pomodoro.sh" \
                         click_script="$PLUGIN_DIR/pomodoro_popup.sh"

sketchybar --add item pomodoro.status popup.pomodoro \
           --set pomodoro.status icon="󰔟" \
                                icon.color=0xff8aadf4 \
                                icon.font="JetBrainsMono Nerd Font:Bold:16.0" \
                                icon.padding_left=8 \
                                icon.padding_right=8 \
                                label="Ready to Focus" \
                                label.color=0xffffffff \
                                label.font="JetBrainsMono Nerd Font:Bold:13.0" \
                                background.color=0x00ffffff

sketchybar --add item pomodoro.control popup.pomodoro \
           --set pomodoro.control icon="󰐊" \
                                 icon.color=0xffa6da95 \
                                 icon.font="JetBrainsMono Nerd Font:Bold:16.0" \
                                 icon.padding_left=8 \
                                 icon.padding_right=8 \
                                 label="Start Timer" \
                                 label.color=0xffffffff \
                                 label.font="JetBrainsMono Nerd Font:Medium:12.0" \
                                 background.color=0x20ffffff \
                                 background.corner_radius=6 \
                                 background.height=24 \
                                 click_script="$PLUGIN_DIR/pomodoro_control.sh start"

sketchybar --add item pomodoro.reset popup.pomodoro \
           --set pomodoro.reset icon="󰑐" \
                               icon.color=0xffed8796 \
                               icon.font="JetBrainsMono Nerd Font:Medium:14.0" \
                               icon.padding_left=8 \
                               icon.padding_right=8 \
                               label="Reset Timer" \
                               label.color=0xffffffff \
                               label.font="JetBrainsMono Nerd Font:Medium:12.0" \
                               background.color=0x20ffffff \
                               background.corner_radius=6 \
                               background.height=24 \
                               click_script="$PLUGIN_DIR/pomodoro_control.sh reset"

sketchybar --add item pomodoro.separator popup.pomodoro \
           --set pomodoro.separator icon="─" \
                                   icon.color=0x50ffffff \
                                   icon.font="JetBrainsMono Nerd Font:Light:12.0" \
                                   label="Configuration" \
                                   label.color=0x80ffffff \
                                   label.font="JetBrainsMono Nerd Font:Medium:10.0" \
                                   background.color=0x00ffffff

sketchybar --add item pomodoro.work_time popup.pomodoro \
           --set pomodoro.work_time icon="󰔟" \
                                   icon.color=0xff8aadf4 \
                                   icon.font="JetBrainsMono Nerd Font:Medium:14.0" \
                                   icon.padding_left=8 \
                                   icon.padding_right=8 \
                                   label="Work: 25 min" \
                                   label.color=0xffffffff \
                                   label.font="JetBrainsMono Nerd Font:Medium:12.0" \
                                   background.color=0x15ffffff \
                                   background.corner_radius=6 \
                                   background.height=24 \
                                   click_script="$PLUGIN_DIR/pomodoro_config.sh work"

sketchybar --add item pomodoro.short_break popup.pomodoro \
           --set pomodoro.short_break icon="󰤄" \
                                     icon.color=0xffeed49f \
                                     icon.font="JetBrainsMono Nerd Font:Medium:14.0" \
                                     icon.padding_left=8 \
                                     icon.padding_right=8 \
                                     label="Short Break: 5 min" \
                                     label.color=0xffffffff \
                                     label.font="JetBrainsMono Nerd Font:Medium:12.0" \
                                     background.color=0x15ffffff \
                                     background.corner_radius=6 \
                                     background.height=24 \
                                     click_script="$PLUGIN_DIR/pomodoro_config.sh short"

sketchybar --add item pomodoro.long_break popup.pomodoro \
           --set pomodoro.long_break icon="󰒲" \
                                    icon.color=0xffc6a0f6 \
                                    icon.font="JetBrainsMono Nerd Font:Medium:14.0" \
                                    icon.padding_left=8 \
                                    icon.padding_right=8 \
                                    label="Long Break: 15 min" \
                                    label.color=0xffffffff \
                                    label.font="JetBrainsMono Nerd Font:Medium:12.0" \
                                    background.color=0x15ffffff \
                                    background.corner_radius=6 \
                                    background.height=24 \
                                    click_script="$PLUGIN_DIR/pomodoro_config.sh long"

sketchybar --add item pomodoro.cycles popup.pomodoro \
           --set pomodoro.cycles icon="󰑖" \
                                icon.color=0xffa6da95 \
                                icon.font="JetBrainsMono Nerd Font:Medium:14.0" \
                                icon.padding_left=8 \
                                icon.padding_right=8 \
                                label="Cycles: 0/4" \
                                label.color=0xffffffff \
                                label.font="JetBrainsMono Nerd Font:Medium:12.0" \
                                background.color=0x00ffffff