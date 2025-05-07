#!/data/data/com.termux/files/usr/bin/bash

# Threshold (in m/s) - small value means sensitive
THRESHOLD=1.5

# Duration between sensor reads (seconds)
INTERVAL=0.2

# Alarm function (plays sound or vibrates)
alarm() {
    termux-vibrate -d 1000
    termux-toast "Movement detected! Alarm!"
    # Uncomment below to play a sound file (put alarm.mp3 in $HOME)
    # termux-media-player play $HOME/alarm.mp3
}

echo "Starting bubble level motion detector..."
termux-toast "Bubble level detector started"

termux-sensor -s accelerometer -n $(echo "$INTERVAL * 1000000" | bc) | while read -r line; do
    # Extract x, y, z values
    x=$(echo $line | grep -oP '"x":\K-?[0-9.]+')
    y=$(echo $line | grep -oP '"y":\K-?[0-9.]+')
    z=$(echo $line | grep -oP '"z":\K-?[0-9.]+')

    # Skip if values aren't valid yet
    if [ -z "$x" ] || [ -z "$y" ] || [ -z "$z" ]; then
        continue
    fi

    # Calculate total deviation from gravity (~9.8 m/s)
    magnitude=$(echo "scale=3; sqrt(($x)^2 + ($y)^2 + ($z)^2)" | bc)

    # Deviation from perfect still gravity (~9.8 m/s)
    deviation=$(echo "scale=3; sqrt(($magnitude - 9.8)^2)" | bc)

    # Debug print
    echo "Deviation: $deviation"

    # If deviation > threshold # alarm
    cmp=$(echo "$deviation > $THRESHOLD" | bc)
    if [ "$cmp" -eq 1 ]; then
        alarm
        # Optional: Exit after alarm
        # break
    fi
done
