#!/bin/bash

STATUS_FILE=/tmp/wl-record-status
STATUS="$(cat "$STATUS_FILE" 2>/dev/null)"
if [ -n "$STATUS" ]; then
	PROCESS="$(echo "$STATUS" | head -n 1)"
	FILENAME="$(echo "$STATUS" | tail -n 1)"
fi

if [ "$1" = '-status' ]; then
	if [ -z "$PROCESS" ]; then
		RECORDING=false
		DURATION=""
	else
		RECORDING=true
		DURATION="$(ps -o etime= -p "$PROCESS" | xargs)"
	fi
	if [ "$RECORDING" = true ]; then
		CLASS="recording"
		TOOLTIP="Recording is active. Left Click to stop, right click to cancel."
		ICON="recording"
	else
		CLASS=""
		TOOLTIP="Left click to start recording current monitor, right click to record selection, middle click to record window."
		ICON="idle"
	fi
	printf '{"class": "%s", "tooltip": "%s", "alt": "%s", "text": "%s"}' "$CLASS" "$TOOLTIP" "$ICON" "$DURATION" | jq --unbuffered --compact-output
	exit 0
fi

if [ ! -x "$(command -v wf-recorder)" ]; then
	notify-send "Missing Binary" "wf-recorder not available. Please install it if you wish to use this script." --app-name="wf-recorder" --icon=media-record --urgency=critical
	exit 0
fi

active=$(pactl get-default-source)

filename=$(date +%F_%T.mkv)

DIRECTORY="$HOME/Videos/Recordings"
MONITOR="$(hyprctl activeworkspace -j | jq .monitor | xargs)"

if [ ! -d "$DIRECTORY" ]; then
	mkdir -p "$DIRECTORY"
fi

if [ -z "$PROCESS" ]; then
	if [ -n "$active" ]; then
		RECORDING_DEVICE="$(pactl -f json list sources | jq ".[] | select(.name==\"$active\").properties.\"alsa.card_name\"")"
	else
		RECORDING_DEVICE="None"
	fi
	if [ "$1" = "-secondary" ]; then
		MODE="Selection"
		COARDINATES="$(slurp -c "#FFFFFF")"
		if [ $? -ne 0 ]; then
			notify-send "Recording Cancelled" --app-name="wf-recorder" --icon=media-record
			exit 0
		fi
		wf-recorder -f "$DIRECTORY/$filename" -a "$active" -g "$COARDINATES" >/dev/null 2>&1 &
		pkill -RTMIN+8 waybar
	elif [ "$1" = '-primary' ]; then
		MODE="Monitor - $MONITOR"
		wf-recorder -o "$MONITOR" -f "$DIRECTORY/$filename" -a "$active" >/dev/null 2>&1 &
		pkill -RTMIN+8 waybar
	elif [ "$1" = '-middle' ]; then
		WINDOWS="$(hyprctl clients -j | jq --argjson active "$(hyprctl monitors -j | jq -c '[.[].activeWorkspace.id]')" \
			'.[] | select((.hidden | not) and .workspace.id as $id | $active | contains([$id])) | "\(.class) - \(.title):::\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' -r)"
		if [ -z "$WINDOWS" ]; then
			notify-send "No windows" "There are no windows to select in active workspace(s)." --app-name="wf-recorder" --icon=media-record
			exit 0
		fi
		WINDOW_COORDS="$(echo "$WINDOWS" | awk -F ':::' '{print $2}')"
		COARDINATES="$(echo "$WINDOW_COORDS" | slurp -c '#FFFFFF')"
		if [ $? -ne 0 ]; then
			notify-send "Recording Cancelled" --app-name="wf-recorder" --icon=media-record
			exit 0
		fi
		TITLE=""
		while IFS= read -r line; do
			name=$(printf "%s" "$line" | awk -F ':::' '{print $1}')
			coords=$(printf "%s" "$line" | awk -F ':::' '{print $2}')
			if [ "$coords" = "$COARDINATES" ]; then
				TITLE="$name"
				break
			fi
		done <<<"$WINDOWS"
		MODE="Window - $TITLE"
		if [ $? -ne 0 ]; then
			notify-send "Recording Cancelled" --app-name="wf-recorder" --icon=media-record
			exit 0
		fi
		wf-recorder -f "$DIRECTORY/$filename" -a "$active" -g "$COARDINATES" >/dev/null 2>&1 &
		pkill -RTMIN+8 waybar
	fi
	printf "%s\n%s" "$!" "$filename" | tee "$STATUS_FILE" >/dev/null
	notify-send "Recording Started" "Microphone: $RECORDING_DEVICE\nMode: $MODE" --app-name="wf-recorder" --icon=media-record
else
	echo "" | tee "$STATUS_FILE" >/dev/null
	kill -s SIGINT "$PROCESS"
	while ps -p "$PROCESS" >/dev/null; do wait; done
	if [ "$1" = "-secondary" ]; then
		notify-send "Recording Cancelled" --app-name="wf-recorder" --icon=media-record
		rm -f "$DIRECTORY/$FILENAME"
	else
		name="$(zenity --entry --text "enter a filename")"
		if [ -n "$name" ]; then
			name="$name."
		fi
		extension="${FILENAME##*.}"
		filename="${FILENAME%.*}"
		mv "$DIRECTORY/$FILENAME" "$DIRECTORY/$filename.$name$extension"
		notify-send "Recording Complete" --app-name="wf-recorder" --icon=media-record
	fi
	pkill -RTMIN+8 waybar
fi
