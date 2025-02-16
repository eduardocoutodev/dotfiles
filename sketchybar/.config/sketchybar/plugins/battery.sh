#!/bin/sh

echo "Event received: $SENDER" >> /tmp/sketchybar_debug.log

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

echo "Battery script triggered. Event: $SENDER" >> /tmp/sketchybar_battery.log
date >> /tmp/sketchybar_battery.log

if [ "$PERCENTAGE" = "" ]; then
  echo "Empty percentage, exiting" >> /tmp/sketchybar_battery.log
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON=""
  ;;
  [6-8][0-9]) ICON=""
  ;;
  [3-5][0-9]) ICON=""
  ;;
  [1-2][0-9]) ICON=""
  ;;
  *) ICON=""
esac

if [[ "$CHARGING" != "" ]]; then
  ICON=""
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"
