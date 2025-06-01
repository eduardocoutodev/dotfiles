#!/usr/bin/env sh

POMODORO_DIR="/tmp/sketchybar_pomodoro"
CONFIG_FILE="$POMODORO_DIR/config"
STATE_FILE="$POMODORO_DIR/state"
TIME_FILE="$POMODORO_DIR/time"
CYCLE_FILE="$POMODORO_DIR/cycles"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    WORK_TIME=1500
    SHORT_BREAK=300
    LONG_BREAK=900
fi

CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "idle")
ACTION="$1"

case "$ACTION" in
    "start")
        if [ "$CURRENT_STATE" = "idle" ]; then
            # Start new work session
            echo "work" > "$STATE_FILE"
            echo "$WORK_TIME" > "$TIME_FILE"
            osascript -e 'display notification "Focus time started! 🍅" with title "Pomodoro Timer"'
        elif [ "$CURRENT_STATE" = "work" ]; then
            # Pause work session
            echo "idle" > "$STATE_FILE"
            osascript -e 'display notification "Timer paused ⏸️" with title "Pomodoro Timer"'
        elif [ "$CURRENT_STATE" = "short_break" ] || [ "$CURRENT_STATE" = "long_break" ]; then
            # Skip break, start work
            echo "work" > "$STATE_FILE"
            echo "$WORK_TIME" > "$TIME_FILE"
            osascript -e 'display notification "Break skipped! Back to work! 💪" with title "Pomodoro Timer"'
        fi
        ;;
        
    "reset")
        # Reset timer to initial state
        echo "idle" > "$STATE_FILE"
        echo "$WORK_TIME" > "$TIME_FILE"
        echo "0" > "$CYCLE_FILE"
        osascript -e 'display notification "Timer reset 🔄" with title "Pomodoro Timer"'
        ;;
        
    "skip")
        if [ "$CURRENT_STATE" = "work" ]; then
            # Skip work, go to break
            CYCLES=$(cat "$CYCLE_FILE" 2>/dev/null || echo "0")
            CYCLES=$((CYCLES + 1))
            echo "$CYCLES" > "$CYCLE_FILE"
            
            if [ $((CYCLES % 4)) -eq 0 ]; then
                echo "long_break" > "$STATE_FILE"
                echo "$LONG_BREAK" > "$TIME_FILE"
            else
                echo "short_break" > "$STATE_FILE"
                echo "$SHORT_BREAK" > "$TIME_FILE"
            fi
        elif [ "$CURRENT_STATE" = "short_break" ] || [ "$CURRENT_STATE" = "long_break" ]; then
            # Skip break, start work
            echo "work" > "$STATE_FILE"
            echo "$WORK_TIME" > "$TIME_FILE"
        fi
        ;;
esac

# Close popup after action
sketchybar --set pomodoro popup.drawing=off

$CONFIG_DIR/plugins/pomodoro.sh