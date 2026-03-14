#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/cacarico/techno-haze-tmux
# Description : Gets RAM usage with threshold-based coloring
# Dependencies: /proc/meminfo (Linux)
# Output      : Tmux-formatted colored RAM usage (e.g., "#[fg=#B39DDB]8.5GB/16GB")
# -----------------------------------------------------------------------------

set -euo pipefail

# Read user options from tmux at runtime
get_option() { tmux show-option -gqv "$1" 2>/dev/null || true; }
COLOR=$(get_option "@technohaze-ram-color");                         COLOR="${COLOR:-#B39DDB}"
WARNING_COLOR=$(get_option "@technohaze-ram-warning-color");         WARNING_COLOR="${WARNING_COLOR:-#FFB86C}"
ALERT_COLOR=$(get_option "@technohaze-ram-alert-color");             ALERT_COLOR="${ALERT_COLOR:-#E06666}"
WARNING_THRESHOLD=$(get_option "@technohaze-ram-warning-threshold"); WARNING_THRESHOLD="${WARNING_THRESHOLD:-80}"
THRESHOLD=$(get_option "@technohaze-ram-threshold");                 THRESHOLD="${THRESHOLD:-90}"

if [[ ! -r /proc/meminfo ]]; then
    echo "#[fg=${COLOR}]0.0GB/0GB"; exit 0
fi

mem_total_kb=""
mem_available_kb=""

while IFS=': ' read -r key value unit; do
    # IFS=': ' splits on colon and space. For "MemTotal:       8042696 kB":
    # colon produces empty field (non-whitespace delimiter, not collapsed),
    # then spaces are collapsed (whitespace in IFS). Result: key=MemTotal, value=8042696, unit=kB.
    case "$key" in
        MemTotal)     mem_total_kb="${value// /}" ;;
        MemAvailable) mem_available_kb="${value// /}" ;;
    esac
    [[ -n "$mem_total_kb" && -n "$mem_available_kb" ]] && break
done < /proc/meminfo

if [[ ! "$mem_total_kb" =~ ^[0-9]+$ ]] || [[ ! "$mem_available_kb" =~ ^[0-9]+$ ]]; then
    echo "#[fg=${COLOR}]0.0GB/0GB"; exit 0
fi

mem_used_kb=$((mem_total_kb - mem_available_kb))
mem_total_gb=$((mem_total_kb / 1048576))
mem_used_gb_int=$((mem_used_kb * 10 / 1048576))
mem_used_percent=$((mem_used_kb * 100 / mem_total_kb))

if [[ $mem_used_percent -gt $THRESHOLD ]]; then
    fg="$ALERT_COLOR"
elif [[ $mem_used_percent -gt $WARNING_THRESHOLD ]]; then
    fg="$WARNING_COLOR"
else
    fg="$COLOR"
fi

printf "#[fg=%s]%d.%dGB/%dGB\n" "$fg" $((mem_used_gb_int / 10)) $((mem_used_gb_int % 10)) "$mem_total_gb"
