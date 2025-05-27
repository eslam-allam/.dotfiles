#!/usr/bin/env bash

EMAIL_CLIENT="thunderbird"

if [ -z "$(pgrep -x $EMAIL_CLIENT)" ]; then
  $EMAIL_CLIENT &
else
  hyprctl dispatch togglespecialworkspace email
fi
