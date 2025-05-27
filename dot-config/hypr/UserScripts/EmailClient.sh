#!/usr/bin/env bash

EMAIL_CLIENT="thunderbird"
EMAIL_CLIENT_CLASS="thunderbird"

EMAIL_OPEN="$(pgrep -x $EMAIL_CLIENT)"

if [ -z "$(hyprctl workspaces -j | jq '.[] | select(.name=="special:email")')" ] && [ -n "$EMAIL_OPEN" ]; then
	hyprctl dispatch movetoworkspace special:email,class:"$EMAIL_CLIENT_CLASS"
elif [ -z "$EMAIL_OPEN" ]; then
	$EMAIL_CLIENT &
else
	hyprctl dispatch togglespecialworkspace email
fi
