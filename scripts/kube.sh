#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/cacarico/techno-haze-tmux
# Description : Gets current Kubernetes context and namespace with coloring
# Dependencies: awk (reads kubeconfig directly, no kubectl needed)
# Output      : Tmux-formatted colored "context(namespace)", red if prod regex matches
# -----------------------------------------------------------------------------

set -euo pipefail

DEFAULT_OUTPUT="k8s:N/A"
KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# Read user options from tmux at runtime
get_option() { tmux show-option -gqv "$1" 2>/dev/null || true; }
COLOR=$(get_option "@technohaze-kube-color");             COLOR="${COLOR:-#6BAFED}"
ALERT_COLOR=$(get_option "@technohaze-kube-alert-color"); ALERT_COLOR="${ALERT_COLOR:-#E06666}"
PROD_REGEX=$(get_option "@technohaze-prod-regex");        PROD_REGEX="${PROD_REGEX:-prod}"

if [[ ! -f "$KUBECONFIG" ]]; then
    echo "#[fg=${COLOR}]${DEFAULT_OUTPUT}"; exit 0
fi

result=$(awk -v default_output="$DEFAULT_OUTPUT" '
/^current-context:/ { current = $2 }
/^[[:space:]]*-[[:space:]]*context:/   { ctx_ns = "default" }
/^[[:space:]]+namespace:/              { split($0, a, /:[[:space:]]*/); ctx_ns = a[2] }
/^[[:space:]]+name:/                   { split($0, a, /:[[:space:]]*/); contexts[a[2]] = ctx_ns }
END {
    if (current == "" || !(current in contexts))
        print default_output
    else
        print current "(" contexts[current] ")"
}
' "$KUBECONFIG")

shopt -s nocasematch
matched=0
[[ "$result" =~ $PROD_REGEX ]] && matched=1 || true
shopt -u nocasematch
if [[ $matched -eq 1 ]]; then
    echo "#[fg=${ALERT_COLOR}]${result}"
else
    echo "#[fg=${COLOR}]${result}"
fi
