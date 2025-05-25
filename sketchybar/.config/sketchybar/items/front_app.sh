  #!/usr/bin/env sh

sketchybar --add item front_app left \
           --set front_app background.color=0x20ffffff \
                          background.corner_radius=10 \
                          background.height=26 \
                          background.border_width=1 \
                          background.border_color=0x30ffffff \
                          icon.color=0xffffffff \
                          icon.font="$FONT:Medium:15.0" \
                          icon.padding_left=10 \
                          icon.padding_right=6 \
                          label.color=0xffffffff \
                          label.font="$FONT:Medium:13.0" \
                          label.padding_right=12 \
                          label.max_chars=20 \
                          script="$PLUGIN_DIR/front_app.sh" \
                          click_script="open -a 'Mission Control'" \
           --subscribe front_app front_app_switched mouse.entered mouse.exited