#!/bin/sh

TIME=$(date +'%H:%M')
DATE=$(date +'%d %b %a')

# Update the clock with clean formatting
sketchybar --set $NAME label="$DATE | $TIME"

