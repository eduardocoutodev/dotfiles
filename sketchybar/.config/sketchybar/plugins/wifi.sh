#!/usr/bin/env sh

WIFI_DEVICE=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
WIFI_STATUS=$(ifconfig $WIFI_DEVICE 2>/dev/null | grep "status:" | cut -d' ' -f2)
SIGNAL_STRENGTH=$(system_profiler SPAirPortDataType 2>/dev/null | grep -A1 "Current Network Information:" -A20 | grep "Signal / Noise" | awk '{print $4}' | cut -d'/' -f1)

if [ "$WIFI_STATUS" = "active" ] && [ -n "$WIFI_DEVICE" ]; then
    # Get initial byte counts
    INITIAL_RX=$(netstat -ibn | grep "$WIFI_DEVICE" | head -1 | awk '{print $7}')
    INITIAL_TX=$(netstat -ibn | grep "$WIFI_DEVICE" | head -1 | awk '{print $10}')
    
    # Store previous values for comparison (use temp files)
    TEMP_DIR="/tmp/sketchybar_wifi"
    mkdir -p "$TEMP_DIR"
    
    PREV_RX_FILE="$TEMP_DIR/prev_rx"
    PREV_TX_FILE="$TEMP_DIR/prev_tx"
    PREV_TIME_FILE="$TEMP_DIR/prev_time"
    
    CURRENT_TIME=$(date +%s)
    
    # Read previous values if they exist
    if [ -f "$PREV_RX_FILE" ] && [ -f "$PREV_TX_FILE" ] && [ -f "$PREV_TIME_FILE" ]; then
        PREV_RX=$(cat "$PREV_RX_FILE")
        PREV_TX=$(cat "$PREV_TX_FILE")
        PREV_TIME=$(cat "$PREV_TIME_FILE")
        
        # Calculate time difference
        TIME_DIFF=$((CURRENT_TIME - PREV_TIME))
        
        if [ $TIME_DIFF -gt 0 ]; then
            # Calculate speeds (bytes per second)
            RX_SPEED=$(((INITIAL_RX - PREV_RX) / TIME_DIFF))
            TX_SPEED=$(((INITIAL_TX - PREV_TX) / TIME_DIFF))
            
            # Convert to human readable format
            if [ $RX_SPEED -gt 1048576 ]; then
                # Convert to MB/s
                RX_DISPLAY=$(echo "scale=1; $RX_SPEED / 1048576" | bc -l 2>/dev/null)M
            elif [ $RX_SPEED -gt 1024 ]; then
                # Convert to KB/s
                RX_DISPLAY=$(echo "scale=0; $RX_SPEED / 1024" | bc -l 2>/dev/null)K
            else
                # Display in B/s
                RX_DISPLAY="${RX_SPEED}B"
            fi
            
            if [ $TX_SPEED -gt 1048576 ]; then
                # Convert to MB/s
                TX_DISPLAY=$(echo "scale=1; $TX_SPEED / 1048576" | bc -l 2>/dev/null)M
            elif [ $TX_SPEED -gt 1024 ]; then
                # Convert to KB/s
                TX_DISPLAY=$(echo "scale=0; $TX_SPEED / 1024" | bc -l 2>/dev/null)K
            else
                # Display in B/s
                TX_DISPLAY="${TX_SPEED}B"
            fi
        else
            RX_DISPLAY="0"
            TX_DISPLAY="0"
        fi
    else
        RX_DISPLAY="--"
        TX_DISPLAY="--"
    fi
    
    # Store current values for next iteration
    echo "$INITIAL_RX" > "$PREV_RX_FILE"
    echo "$INITIAL_TX" > "$PREV_TX_FILE"
    echo "$CURRENT_TIME" > "$PREV_TIME_FILE"
else
    RX_DISPLAY="--"
    TX_DISPLAY="--"
fi

# Determine WiFi icon and color based on signal strength and status
if [ "$WIFI_STATUS" = "active" ]; then
    if [ -n "$SIGNAL_STRENGTH" ]; then
        SIGNAL_NUM=$(echo $SIGNAL_STRENGTH | tr -d 'dBm-')
        if [ "$SIGNAL_NUM" -le 50 ]; then
            # Excellent signal (-50 dBm or better)
            WIFI_ICON="󰤨"
            WIFI_COLOR=0xffa6da95  # Green
        elif [ "$SIGNAL_NUM" -le 60 ]; then
            # Good signal (-51 to -60 dBm)
            WIFI_ICON="󰤥"
            WIFI_COLOR=0xff8aadf4  # Blue
        elif [ "$SIGNAL_NUM" -le 70 ]; then
            # Fair signal (-61 to -70 dBm)
            WIFI_ICON="󰤢"
            WIFI_COLOR=0xffeed49f  # Yellow
        else
            # Poor signal (-71 dBm or worse)
            WIFI_ICON="󰤟"
            WIFI_COLOR=0xffed8796  # Red
        fi
    else
        # Connected but can't determine signal strength
        WIFI_ICON="󰤨"
        WIFI_COLOR=0xff8aadf4  # Blue
    fi
else
    # Not connected
    WIFI_ICON="󰤭"
    WIFI_COLOR=0xffed8796  # Red
    RX_DISPLAY="--"
    TX_DISPLAY="--"
fi

# Update the WiFi indicator with speeds
sketchybar --set wifi icon="$WIFI_ICON" \
                    icon.color=$WIFI_COLOR \
                    label="↓ $RX_DISPLAY ↑ $TX_DISPLAY"