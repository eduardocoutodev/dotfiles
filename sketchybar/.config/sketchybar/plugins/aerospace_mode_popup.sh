#!/usr/bin/env sh

if [ "$(sketchybar --query aerospace.mode | jq -r '.popup.drawing')" = "on" ]; then
    sketchybar --set aerospace.mode popup.drawing=off
else
    sketchybar --set aerospace.mode popup.drawing=on
fi