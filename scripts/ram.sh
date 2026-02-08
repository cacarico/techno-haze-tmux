#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/cacarico/techno-haze-tmux
# Description : Gets RAM usage
# Dependencies: /proc/meminfo (Linux)
# Output      : RAM usage in format "used_GB/total_GB" (e.g., "8.5GB/16GB")
# -----------------------------------------------------------------------------

set -euo pipefail

DEFAULT_OUTPUT="0.0GB/0GB"

# Validate /proc/meminfo exists
if [[ ! -r /proc/meminfo ]]; then
    echo "$DEFAULT_OUTPUT"
    exit 0
fi

# Single-pass read of both values
mem_total_kb=""
mem_available_kb=""

while IFS=': ' read -r key value unit; do
    case "$key" in
        MemTotal) mem_total_kb="${value// /}" ;;
        MemAvailable) mem_available_kb="${value// /}" ;;
    esac
    # Exit early once we have both values
    [[ -n "$mem_total_kb" && -n "$mem_available_kb" ]] && break
done < /proc/meminfo

# Validate numeric values
if [[ ! "$mem_total_kb" =~ ^[0-9]+$ ]] || [[ ! "$mem_available_kb" =~ ^[0-9]+$ ]]; then
    echo "$DEFAULT_OUTPUT"
    exit 0
fi

# Calculate used memory
mem_used_kb=$((mem_total_kb - mem_available_kb))

# Convert to GB using bash arithmetic (1048576 = 1024*1024)
mem_total_gb=$((mem_total_kb / 1048576))
mem_used_gb_int=$((mem_used_kb * 10 / 1048576))

# Format output: X.XGB/YYGB
printf "%d.%dGB/%dGB\n" $((mem_used_gb_int / 10)) $((mem_used_gb_int % 10)) "$mem_total_gb"
