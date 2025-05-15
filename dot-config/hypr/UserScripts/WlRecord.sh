#!/bin/sh

active=$(pactl get-default-source)

filename=$(date +%F_%T.mkv)

DIRECTORY="$HOME/Videos/Recordings"
MONITOR="$(hyprctl activeworkspace -j | jq .monitor | xargs)"

if [ ! -d "$DIRECTORY" ]; then
  echo "Creating $DIRECTORY"
    mkdir -p "$DIRECTORY"
fi

echo active sink: $active 
echo $filename

if [ -z $(pgrep wf-recorder) ];
	then 
    notify-send "Recording Started ($active)"
    if [ "$1" = "-s" ]
      then 
        COARDINATES="$(slurp -c "#FFFFFF")"
        wf-recorder -f "$DIRECTORY/$filename" -a "$active" -g "$COARDINATES" >/dev/null 2>&1 &
        pkill -RTMIN+8 waybar
    else
      wf-recorder -o "$MONITOR" -f "$DIRECTORY/$filename" -a "$active" >/dev/null 2>&1 &
      pkill -RTMIN+8 waybar
    fi
else
	killall -s SIGINT wf-recorder
	notify-send "Recording Complete"
	while [ ! -z $(pgrep -x wf-recorder) ]; do wait; done
	pkill -RTMIN+8 waybar
	name="$(zenity --entry --text "enter a filename")"
	perl-rename "s/\.(mkv|mp4)$/ $name $&/" "$(ls -d "$DIRECTORY"/* -t | head -n1)"
fi
