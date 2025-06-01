#!/usr/bin/env sh

POMODORO_DIR="/tmp/sketchybar_pomodoro"
mkdir -p "$POMODORO_DIR"

CONFIG_FILE="$POMODORO_DIR/config"
STATE_FILE="$POMODORO_DIR/state"
TIME_FILE="$POMODORO_DIR/time"
CYCLE_FILE="$POMODORO_DIR/cycles"

# Default configuration
DEFAULT_WORK_TIME=1500      # 25 minutes in seconds
DEFAULT_SHORT_BREAK=300     # 5 minutes in seconds
DEFAULT_LONG_BREAK=900      # 15 minutes in seconds
DEFAULT_LONG_BREAK_AFTER=4  # Long break after 4 cycles

# Initialize config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "WORK_TIME=$DEFAULT_WORK_TIME" > "$CONFIG_FILE"
    echo "SHORT_BREAK=$DEFAULT_SHORT_BREAK" >> "$CONFIG_FILE"
    echo "LONG_BREAK=$DEFAULT_LONG_BREAK" >> "$CONFIG_FILE"
    echo "LONG_BREAK_AFTER=$DEFAULT_LONG_BREAK_AFTER" >> "$CONFIG_FILE"
fi

# Initialize state if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "idle" > "$STATE_FILE"           # idle, work, short_break, long_break
    echo "$DEFAULT_WORK_TIME" > "$TIME_FILE"  # remaining time in seconds
    echo "0" > "$CYCLE_FILE"              # completed work cycles
fi

# Load configuration
source "$CONFIG_FILE"

# Read current state
CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "idle")
REMAINING_TIME=$(cat "$TIME_FILE" 2>/dev/null || echo "$WORK_TIME")
CYCLES=$(cat "$CYCLE_FILE" 2>/dev/null || echo "0")

format_time() {
    local total_seconds=$1
    local minutes=$((total_seconds / 60))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d" $minutes $seconds
}

case "$CURRENT_STATE" in
    "work")
        # Work session
        if [ $REMAINING_TIME -gt 0 ]; then
            # Countdown
            REMAINING_TIME=$((REMAINING_TIME - 1))
            echo "$REMAINING_TIME" > "$TIME_FILE"
            
            # Update display
            sketchybar --set pomodoro icon="󰔟" \
                                    icon.color=0xff8aadf4 \
                                    label="$(format_time $REMAINING_TIME)" \
                                    background.border_color=0xff8aadf4
            
            # Update popup status
            sketchybar --set pomodoro.status label="Working... Focus!" \
                                            icon="󰔟" \
                                            icon.color=0xff8aadf4
            sketchybar --set pomodoro.control label="Pause Timer" \
                                             icon="󰏤" \
                                             icon.color=0xffeed49f
        else
            # Work session completed
            CYCLES=$((CYCLES + 1))
            echo "$CYCLES" > "$CYCLE_FILE"
            
            # Determine next break type
            if [ $((CYCLES % LONG_BREAK_AFTER)) -eq 0 ]; then
                # Time for long break
                echo "long_break" > "$STATE_FILE"
                echo "$LONG_BREAK" > "$TIME_FILE"
                osascript -e 'display notification "Time for a long break! 🎉" with title "Pomodoro Timer"'
            else
                # Time for short break
                echo "short_break" > "$STATE_FILE"
                echo "$SHORT_BREAK" > "$TIME_FILE"
                osascript -e 'display notification "Time for a short break! ☕" with title "Pomodoro Timer"'
            fi
        fi
        ;;
        
    "short_break")
        # Short break
        if [ $REMAINING_TIME -gt 0 ]; then
            REMAINING_TIME=$((REMAINING_TIME - 1))
            echo "$REMAINING_TIME" > "$TIME_FILE"
            
            sketchybar --set pomodoro icon="󰤄" \
                                    icon.color=0xffeed49f \
                                    label="$(format_time $REMAINING_TIME)" \
                                    background.border_color=0xffeed49f
            
            sketchybar --set pomodoro.status label="Short Break - Relax!" \
                                            icon="󰤄" \
                                            icon.color=0xffeed49f
            sketchybar --set pomodoro.control label="Skip Break" \
                                             icon="󰒭" \
                                             icon.color=0xff8aadf4
        else
            # Break completed, back to work
            echo "work" > "$STATE_FILE"
            echo "$WORK_TIME" > "$TIME_FILE"
            osascript -e 'display notification "Break over! Back to work! 💪" with title "Pomodoro Timer"'
        fi
        ;;
        
    "long_break")
        # Long break
        if [ $REMAINING_TIME -gt 0 ]; then
            REMAINING_TIME=$((REMAINING_TIME - 1))
            echo "$REMAINING_TIME" > "$TIME_FILE"
            
            sketchybar --set pomodoro icon="󰒲" \
                                    icon.color=0xffc6a0f6 \
                                    label="$(format_time $REMAINING_TIME)" \
                                    background.border_color=0xffc6a0f6
            
            sketchybar --set pomodoro.status label="Long Break - Recharge!" \
                                            icon="󰒲" \
                                            icon.color=0xffc6a0f6
            sketchybar --set pomodoro.control label="Skip Break" \
                                             icon="󰒭" \
                                             icon.color=0xff8aadf4
        else
            # Long break completed, back to work
            echo "work" > "$STATE_FILE"
            echo "$WORK_TIME" > "$TIME_FILE"
            osascript -e 'display notification "Long break over! Ready for more focus! 🚀" with title "Pomodoro Timer"'
        fi
        ;;
        
    *)
        # Idle state
        sketchybar --set pomodoro icon="󰔟" \
                                icon.color=0x808aadf4 \
                                label="$(format_time $WORK_TIME)" \
                                background.border_color=0x30ffffff
        
        sketchybar --set pomodoro.status label="Ready to Focus" \
                                        icon="󰔟" \
                                        icon.color=0xff8aadf4
        sketchybar --set pomodoro.control label="Start Timer" \
                                         icon="󰐊" \
                                         icon.color=0xffa6da95
        ;;
esac

sketchybar --set pomodoro.cycles label="Cycles: $CYCLES/$LONG_BREAK_AFTER"