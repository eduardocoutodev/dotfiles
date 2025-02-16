#!/bin/bash

update_volume() {
  VOLUME=$(osascript -e "output volume of (get volume settings)")
  MUTED=$(osascript -e "output muted of (get volume settings)")

  if [[ $MUTED == "true" ]]; then
    ICON="󰝟"
    VOLUME="muted"
  else
    case ${VOLUME} in
      100) ICON="󰕾";;
      [5-9][0-9]) ICON="󰕾";;
      [1-4][0-9]) ICON="󰖀";;
      [1-9]) ICON="󰕿";;
      0) ICON="󰝟";;
    esac
  fi

  sketchybar --set $NAME icon="$ICON" label="$VOLUME%"
}

create_slider() {
  # Remove the slider if it already exists
  sketchybar --remove volume.slider 2>/dev/null
  sketchybar --remove volume.percentage 2>/dev/null

  # Create new slider
  sketchybar --add slider volume.slider popup.volume \
             --set volume.slider \
                   icon.drawing=off \
                   label.drawing=off \
                   background.height=6 \
                   background.corner_radius=3 \
                   background.color=0x40ffffff \
                   knob.color=$WHITE \
                   knob.size=10 \
                   slider.highlight_color=$WHITE \
                   slider.background.height=6 \
                   slider.background.corner_radius=3 \
                   slider.background.color=0x40ffffff \
                   slider.value=$(osascript -e "output volume of (get volume settings)") \
                   slider.width=100 \
                   script="$PLUGIN_DIR/volume.sh" \
             --subscribe volume.slider mouse.clicked mouse.entered mouse.exited

  # Create percentage label
  sketchybar --add item volume.percentage popup.volume \
             --set volume.percentage \
                   icon.drawing=off \
                   label="$(osascript -e "output volume of (get volume settings)")%"
}

case "$SENDER" in
  "volume_change")
    update_volume
    ;;
  "mouse.clicked")
    case "$NAME" in
      "volume")
        if [[ "$(sketchybar --query volume | jq -r ".popup.drawing")" == "true" ]]; then
          sketchybar --set volume popup.drawing=off
        else
          create_slider
          sketchybar --set volume popup.drawing=on
        fi
        ;;
      "volume.slider")
        osascript -e "set volume output volume $PERCENTAGE"
        sketchybar --set volume.percentage label="$PERCENTAGE%"
        ;;
    esac
    ;;
  "mouse.entered")
    sketchybar --set volume.slider slider.knob.drawing=on
    ;;
  "mouse.exited")
    sketchybar --set volume.slider slider.knob.drawing=off
    ;;
  *)
    update_volume
    ;;
esac