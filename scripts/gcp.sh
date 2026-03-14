#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/cacarico/techno-haze-tmux
# Description : Gets current GCP project from gcloud config files with coloring
# Dependencies: awk (reads gcloud config directly, no gcloud CLI needed)
# Output      : Tmux-formatted colored GCP project, red if prod regex matches
# -----------------------------------------------------------------------------

set -euo pipefail

DEFAULT_OUTPUT="gcp:N/A"
GCLOUD_CONFIG_DIR="${CLOUDSDK_CONFIG:-$HOME/.config/gcloud}"
ACTIVE_CONFIG_FILE="$GCLOUD_CONFIG_DIR/active_config"

# Read user options from tmux at runtime
get_option() { tmux show-option -gqv "$1" 2>/dev/null || true; }
COLOR=$(get_option "@technohaze-gcp-color");             COLOR="${COLOR:-#3A7BD5}"
ALERT_COLOR=$(get_option "@technohaze-gcp-alert-color"); ALERT_COLOR="${ALERT_COLOR:-#E06666}"
PROD_REGEX=$(get_option "@technohaze-prod-regex");       PROD_REGEX="${PROD_REGEX:-prod}"

if [[ ! -f "$ACTIVE_CONFIG_FILE" ]]; then
    echo "#[fg=${COLOR}]${DEFAULT_OUTPUT}"; exit 0
fi

read -r active_config < "$ACTIVE_CONFIG_FILE" || true
if [[ ! "$active_config" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "#[fg=${COLOR}]${DEFAULT_OUTPUT}"; exit 0
fi
config_file="$GCLOUD_CONFIG_DIR/configurations/config_${active_config}"

if [[ ! -f "$config_file" ]]; then
    echo "#[fg=${COLOR}]${DEFAULT_OUTPUT}"; exit 0
fi

result=$(awk -v default_output="$DEFAULT_OUTPUT" '
/^\[core\]/  { in_core = 1; next }
/^\[/        { in_core = 0 }
in_core && /^project[[:space:]]*=/ {
    sub(/^project[[:space:]]*=[[:space:]]*/, "")
    print
    found = 1
    exit
}
END { if (!found) print default_output }
' "$config_file")

shopt -s nocasematch
matched=0
[[ "$result" =~ $PROD_REGEX ]] && matched=1 || true
shopt -u nocasematch
if [[ $matched -eq 1 ]]; then
    echo "#[fg=${ALERT_COLOR}]${result}"
else
    echo "#[fg=${COLOR}]${result}"
fi
