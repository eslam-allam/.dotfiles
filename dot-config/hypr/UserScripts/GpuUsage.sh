#!/bin/bash

GPU_INFO=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits)
GPU_UTIL=$(echo "$GPU_INFO" | cut -d "," -f 1 | tr -d ' ')
GPU_TEMPERATURE=$(echo "$GPU_INFO" | cut -d "," -f 2 | tr -d ' ')

CSS_CLASS="low"

if ((GPU_UTIL > 30 && GPU_UTIL < 60)); then
	CSS_CLASS="medium"
fi

if ((GPU_UTIL > 60 )); then
	CSS_CLASS="high"
fi


printf '{"percentage": %s, "text": "%s", "class": "%s", "tooltip": "Gpu Utilization is %s and temperature is %s"}' "$GPU_UTIL" "$GPU_TEMPERATURE" $CSS_CLASS "$GPU_UTIL"% "$GPU_TEMPERATURE"c | jq --unbuffered --compact-output
