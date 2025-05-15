#!/bin/bash

GPU_INFO=$(nvidia-smi --query-gpu=utilization.memory,memory.used --format=csv,noheader,nounits)
GPU_MEMORY_UTIL=$(echo "$GPU_INFO" | cut -d "," -f 1 | tr -d ' ')
GPU_MEMORY_USED=$(echo "$GPU_INFO" | cut -d "," -f 2 | tr -d ' ')

CSS_CLASS="low"

if ((GPU_MEMORY_UTIL > 30 && GPU_MEMORY_UTIL < 60)); then
	CSS_CLASS="medium"
fi

if ((GPU_MEMORY_UTIL > 60 )); then
	CSS_CLASS="high"
fi


printf '{"percentage": %s, "text": "%s", "class": "%s", "tooltip": "Memory utilization is %s and Memory used is %s MB"}' "$GPU_MEMORY_UTIL" "$GPU_MEMORY_USED" $CSS_CLASS "$GPU_MEMORY_UTIL"% "$GPU_MEMORY_USED" | jq --unbuffered --compact-output
