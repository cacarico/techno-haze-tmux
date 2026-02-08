#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/cacarico/techno-haze-tmux
# Description : Gets CPU usage as percentage
# Dependencies: /proc/stat (Linux), awk
# Output      : CPU usage percentage (e.g., "45.3%")
# -----------------------------------------------------------------------------

set -euo pipefail

# Configuration
# Use single cache file per user for simplicity and reliability
CACHE_FILE="/tmp/techno-haze-cpu-${USER:-$(whoami)}"
DEFAULT_OUTPUT="0.0%"

# Validate /proc/stat exists (Linux-specific)
if [[ ! -r /proc/stat ]]; then
    echo "$DEFAULT_OUTPUT"
    exit 0
fi

# Read current CPU stats (first line of /proc/stat)
read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat 2>/dev/null || {
    echo "$DEFAULT_OUTPUT"
    exit 0
}

# Default missing fields to zero
: "${iowait:=0}" "${irq:=0}" "${softirq:=0}" "${steal:=0}" "${guest:=0}" "${guest_nice:=0}"

# Validate numeric values
if [[ ! "$user" =~ ^[0-9]+$ ]] || [[ ! "$idle" =~ ^[0-9]+$ ]]; then
    echo "$DEFAULT_OUTPUT"
    exit 0
fi

# Calculate total ticks (sum all CPU time fields)
total=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))

# Read previous values if they exist
if [[ -f "$CACHE_FILE" ]]; then
    read prev_total prev_idle < "$CACHE_FILE"

    # Calculate deltas
    total_delta=$((total - prev_total))
    idle_delta=$((idle - prev_idle))

    # Avoid division by zero
    if [[ $total_delta -gt 0 ]]; then
        # Calculate CPU usage: (1 - idle/total) * 100
        # Use fixed-point arithmetic for precision
        cpu_usage=$(( ((total_delta - idle_delta) * 1000) / total_delta ))
        printf "%.1f%%\n" "$(awk "BEGIN {print $cpu_usage / 10}")"
    else
        echo "$DEFAULT_OUTPUT"
    fi
else
    # First run - initialize cache
    echo "$DEFAULT_OUTPUT"
fi

# Store current values for next run
echo "$total $idle" > "$CACHE_FILE"
