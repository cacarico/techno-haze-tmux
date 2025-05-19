#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Name        : Caio Quinilato Teixeira
# Email       : caio.quinilato@gmail.com
# Repository  : https://github.com/github/dotfiles
# Description : FZF-based project launcher for tmux
# -----------------------------------------------------------------------------

# set -euo pipefail
trap 'echo "[project.sh] Error on line $LINENO"; exit 2' ERR

project_launch() {
    local session_name="$1"
    local window_name="$2"
    local project_dir="$3"
    local editor="$4"

    tmux new-window -t "${session_name}" -n "${window_name}" -c "${project_dir}"
    tmux split-window -t "${session_name}:${window_name}" -v -c "${project_dir}"
    tmux resize-pane -t "${session_name}:${window_name}" -y 20%
    tmux send-keys -t "${session_name}:${window_name}" clear C-m
    tmux select-pane -t "${session_name}:${window_name}" -U
    tmux send-keys -t "${session_name}:${window_name}" clear C-m
    tmux send-keys -t "${session_name}:${window_name}" "$editor" C-m
}

main() {

    local projects="$1"
    local editor="$2"

    selected=$(find "$projects" -mindepth 3 -maxdepth 3 -type d,l 2>/dev/null | fzf)
    [[ -z "$selected" ]] && exit 0

    local window_name
    window_name=$(basename "$selected")

    local session_name
    session_name=$(tmux display-message -p '#S')

    if [[ -n "$session_name" ]]; then
        project_launch "$session_name" "$window_name" "$selected" "$editor"
    else
        echo "No attached tmux session found." >&2
        exit 1
    fi
}

main "$@"
