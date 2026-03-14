#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/cacarico/techno-haze-tmux
# Description : Gets CPU usage as percentage with threshold-based coloring
# Dependencies: /proc/stat (Linux)
# Output      : Tmux-formatted colored CPU usage (e.g., "#[fg=#B39DDB]45.3%")
# -----------------------------------------------------------------------------

set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/techno-haze-tmux"
mkdir -p "$CACHE_DIR"
CACHE_FILE="$CACHE_DIR/cpu"

# Read user options from tmux at runtime
get_option() { tmux show-option -gqv "$1" 2>/dev/null || true; }
COLOR=$(get_option "@technohaze-cpu-color");                     COLOR="${COLOR:-#B39DDB}"
WARNING_COLOR=$(get_option "@technohaze-cpu-warning-color");     WARNING_COLOR="${WARNING_COLOR:-#FFB86C}"
ALERT_COLOR=$(get_option "@technohaze-cpu-alert-color");         ALERT_COLOR="${ALERT_COLOR:-#E06666}"
WARNING_THRESHOLD=$(get_option "@technohaze-cpu-warning-threshold"); WARNING_THRESHOLD="${WARNING_THRESHOLD:-75}"
THRESHOLD=$(get_option "@technohaze-cpu-threshold");             THRESHOLD="${THRESHOLD:-85}"

if [[ ! -r /proc/stat ]]; then
    echo "#[fg=${COLOR}]0.0%"; exit 0
fi

read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat 2>/dev/null || {
    echo "#[fg=${COLOR}]0.0%"; exit 0
}

: "${iowait:=0}" "${irq:=0}" "${softirq:=0}" "${steal:=0}" "${guest:=0}" "${guest_nice:=0}"

if [[ ! "$user" =~ ^[0-9]+$ ]] || [[ ! "$idle" =~ ^[0-9]+$ ]]; then
    echo "#[fg=${COLOR}]0.0%"; exit 0
fi

total=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))

if [[ -f "$CACHE_FILE" ]]; then
    read -r prev_total prev_idle < "$CACHE_FILE"
    if [[ ! "$prev_total" =~ ^[0-9]+$ ]] || [[ ! "$prev_idle" =~ ^[0-9]+$ ]]; then
        echo "#[fg=${COLOR}]0.0%"
        echo "$total $idle" > "$CACHE_FILE"
        exit 0
    fi

    total_delta=$((total - prev_total))
    idle_delta=$((idle - prev_idle))

    if [[ $total_delta -gt 0 ]]; then
        cpu_usage=$(( ((total_delta - idle_delta) * 1000) / total_delta ))
        if [[ $cpu_usage -gt $((THRESHOLD * 10)) ]]; then
            fg="$ALERT_COLOR"
        elif [[ $cpu_usage -gt $((WARNING_THRESHOLD * 10)) ]]; then
            fg="$WARNING_COLOR"
        else
            fg="$COLOR"
        fi
        printf "#[fg=%s]%d.%d%%\n" "$fg" $((cpu_usage / 10)) $((cpu_usage % 10))
    else
        echo "#[fg=${COLOR}]0.0%"
    fi
else
    echo "#[fg=${COLOR}]0.0%"
fi

echo "$total $idle" > "$CACHE_FILE"
