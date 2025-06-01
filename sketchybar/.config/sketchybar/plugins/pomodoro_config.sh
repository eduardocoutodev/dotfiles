#!/usr/bin/env sh


POMODORO_DIR="/tmp/sketchybar_pomodoro"
CONFIG_FILE="$POMODORO_DIR/config"
CONFIG_TYPE="$1"

# Load current configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    WORK_TIME=1500
    SHORT_BREAK=300
    LONG_BREAK=900
    LONG_BREAK_AFTER=4
fi

# Function to prompt for time input
prompt_time() {
    local type="$1"
    local current="$2"
    local current_min=$((current / 60))
    
    local new_time
    new_time=$(osascript -e "
        set currentMinutes to $current_min
        set newMinutes to text returned of (display dialog \"Enter $type time in minutes:\" default answer \"$current_min\" with title \"Pomodoro Configuration\")
        return newMinutes
    " 2>/dev/null)
    
    if [ -n "$new_time" ] && [ "$new_time" -gt 0 ] 2>/dev/null; then
        echo $((new_time * 60))
    else
        echo "$current"
    fi
}

case "$CONFIG_TYPE" in
    "work")
        NEW_WORK_TIME=$(prompt_time "work session" "$WORK_TIME")
        if [ "$NEW_WORK_TIME" != "$WORK_TIME" ]; then
            WORK_TIME="$NEW_WORK_TIME"
            # Update config file
            cat > "$CONFIG_FILE" << EOF
WORK_TIME=$WORK_TIME
SHORT_BREAK=$SHORT_BREAK
LONG_BREAK=$LONG_BREAK
LONG_BREAK_AFTER=$LONG_BREAK_AFTER
EOF
            osascript -e 'display notification "Work time updated! ⚙️" with title "Pomodoro Timer"'
        fi
        ;;
        
    "short")
        NEW_SHORT_BREAK=$(prompt_time "short break" "$SHORT_BREAK")
        if [ "$NEW_SHORT_BREAK" != "$SHORT_BREAK" ]; then
            SHORT_BREAK="$NEW_SHORT_BREAK"
            cat > "$CONFIG_FILE" << EOF
WORK_TIME=$WORK_TIME
SHORT_BREAK=$SHORT_BREAK
LONG_BREAK=$LONG_BREAK
LONG_BREAK_AFTER=$LONG_BREAK_AFTER
EOF
            osascript -e 'display notification "Short break time updated! ⚙️" with title "Pomodoro Timer"'
        fi
        ;;
        
    "long")
        NEW_LONG_BREAK=$(prompt_time "long break" "$LONG_BREAK")
        if [ "$NEW_LONG_BREAK" != "$LONG_BREAK" ]; then
            LONG_BREAK="$NEW_LONG_BREAK"
            cat > "$CONFIG_FILE" << EOF
WORK_TIME=$WORK_TIME
SHORT_BREAK=$SHORT_BREAK
LONG_BREAK=$LONG_BREAK
LONG_BREAK_AFTER=$LONG_BREAK_AFTER
EOF
            osascript -e 'display notification "Long break time updated! ⚙️" with title "Pomodoro Timer"'
        fi
        ;;
esac

# Update popup display
$CONFIG_DIR/plugins/pomodoro_popup.sh