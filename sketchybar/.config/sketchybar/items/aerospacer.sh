#!/usr/bin/env sh

sketchybar --add event aerospace_workspace_change

# Create workspace dots with minimal styling
workspace_ids=($(aerospace list-workspaces --all))
space_items=()
for sid in "${workspace_ids[@]}"; do
    space_items+=("space.$sid")
done

# Subtle container for dots
sketchybar --add bracket workspace_dots "${space_items[@]}" \
           --set workspace_dots background.color=0x10ffffff \
                               background.corner_radius=15 \
                               background.height=26 \
                               background.padding_left=8 \
                               background.padding_right=8

# Create minimal dot indicators
for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item "space.$sid" left \
               --subscribe "space.$sid" aerospace_workspace_change \
               --set "space.$sid" \
                     icon="●" \
                     icon.font="JetBrainsMono Nerd Font:Regular:8.0" \
                     icon.color=0x30ffffff \
                     icon.padding_left=4 \
                     icon.padding_right=4 \
                     label.drawing=off \
                     background.drawing=off \
                     click_script="aerospace workspace $sid" \
                     script="$CONFIG_DIR/plugins/aerospacer.sh $sid"
done