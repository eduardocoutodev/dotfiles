#!/usr/bin/env sh

POMODORO_DIR="/tmp/sketchybar_pomodoro"
CONFIG_FILE="$POMODORO_DIR/config"

# Load current configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    WORK_TIME=1500
    SHORT_BREAK=300
    LONG_BREAK=900
    LONG_BREAK_AFTER=4
fi

WORK_MIN=$((WORK_TIME / 60))
SHORT_MIN=$((SHORT_BREAK / 60))
LONG_MIN=$((LONG_BREAK / 60))

sketchybar --set pomodoro.work_time label="Work: $WORK_MIN min"
sketchybar --set pomodoro.short_break label="Short Break: $SHORT_MIN min"
sketchybar --set pomodoro.long_break label="Long Break: $LONG_MIN min"

# Toggle popup visibility
if [ "$(sketchybar --query pomodoro | jq -r '.popup.drawing')" = "on" ]; then
    sketchybar --set pomodoro popup.drawing=off
else
    sketchybar --set pomodoro popup.drawing=on
fi