#!/usr/bin/env bash


main() {
    selected=$(find ~/ghq/ -mindepth 3 -maxdepth 3 -type d | fzf)
    clean=$(echo "$selected" | awk -F/ '{print $NF}')

    if [ "$selected" ]; then
        tmux new-window -c "$selected" -n "$clean"
        tmux send-keys -t 0 nvim Enter
        tmux split-window -c "$selected" -v -l 20%
        tmux select-pane -U
    fi
}

main
