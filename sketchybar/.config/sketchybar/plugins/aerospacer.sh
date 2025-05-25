#!/bin/bash

SID=$1
CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)
OCCUPIED_WORKSPACES=$(aerospace list-workspaces --monitor all --empty no)

# Minimal color palette
ACTIVE_DOT=0xffffffff      # Bright white for active
OCCUPIED_DOT=0x80ffffff    # Medium white for occupied
EMPTY_DOT=0x30ffffff       # Subtle white for empty
ACCENT_DOT=0xff8aadf4      # Blue accent

echo "Dots plugin called with workspace: $SID"
echo "Current workspace: $CURRENT_WORKSPACE"

# Update dot appearance based on state
if [[ "$CURRENT_WORKSPACE" == "$SID" ]]; then
    # Currently active workspace - bright dot
    echo "Setting dot $SID as ACTIVE"
    sketchybar --set "space.$SID" \
                     icon.color=$ACTIVE_DOT \
                     icon.font="JetBrainsMono Nerd Font:Bold:10.0"
                     
elif echo "$OCCUPIED_WORKSPACES" | grep -q "^$SID$"; then
    # Has windows - medium dot
    echo "Setting dot $SID as OCCUPIED"
    sketchybar --set "space.$SID" \
                     icon.color=$OCCUPIED_DOT \
                     icon.font="JetBrainsMono Nerd Font:Medium:9.0"
else
    # Empty workspace - subtle dot
    echo "Setting dot $SID as EMPTY"
    sketchybar --set "space.$SID" \
                     icon.color=$EMPTY_DOT \
                     icon.font="JetBrainsMono Nerd Font:Regular:8.0"
fi

# Brief animation on workspace change
if [ "$SENDER" = "aerospace_workspace_change" ] && [[ "$CURRENT_WORKSPACE" == "$SID" ]]; then
    echo "Animating workspace change to $SID"
    # Quick pulse effect
    sketchybar --set "space.$SID" icon.color=$ACCENT_DOT
    sleep 0.1
    sketchybar --set "space.$SID" icon.color=$ACTIVE_DOT
fi