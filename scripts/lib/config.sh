#!/usr/bin/env bash

# --- Configuration Constants -------------------------------------------------
readonly DEFAULT_TERMINAL="screen-256color"
readonly HISTORY_LIMIT=5000
readonly BASE_INDEX=1
readonly DISPLAY_PANES_TIME=801
readonly DISPLAY_MESSAGE_TIME=1000
readonly STATUS_INTERVAL=10

# --- Tmux Options ------------------------------------------------------------

# Function: setup_config
# Description: Configures tmux global options (prefix, mouse, terminal, history, etc.)
# Parameters: None
# Returns: 0 on success
# Side Effects: Sets multiple tmux global and window options
setup_config() {
    tmux set-option -g prefix M-a
    tmux bind-key M-a send-prefix

    tmux set -g mouse on
    tmux set -g default-terminal "$DEFAULT_TERMINAL"
    tmux set -g history-limit $HISTORY_LIMIT
    tmux set-window-option -g mode-keys vi

    tmux set -g base-index $BASE_INDEX
    tmux set -g renumber-windows on
    tmux set -g display-panes-time $DISPLAY_PANES_TIME
    tmux set -g display-time $DISPLAY_MESSAGE_TIME
    tmux set -g status-interval $STATUS_INTERVAL
    tmux setw -g automatic-rename off

    # Image preview fix (e.g. yazi)
    tmux set -g allow-passthrough on
    tmux set -ga update-environment TERM
    tmux set -ga update-environment TERM_PROGRAM
}
