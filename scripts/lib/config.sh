#!/usr/bin/env bash

# --- Configuration Constants -------------------------------------------------
readonly DEFAULT_TERMINAL="screen-256color"
readonly HISTORY_LIMIT=5000
readonly BASE_INDEX=1
readonly DISPLAY_PANES_TIME=801
readonly DISPLAY_MESSAGE_TIME=1000
readonly STATUS_INTERVAL=10

# --- User Options Initialization ---------------------------------------------

# Function: init_user_options
# Description: Fetches all user-configurable tmux options and exports them as environment variables
# Parameters: None
# Returns: 0 on success
# Side Effects: Exports all TECHNO_HAZE_* environment variables
# Note: This is the single source of truth for all plugin configuration
init_user_options() {
    # Project launcher options
    export TECHNO_HAZE_PROJECTS_DIR="$(get_tmux_option "@technohaze-projects-dir" "$HOME/ghq")"
    export TECHNO_HAZE_EDITOR="$(get_tmux_option "@technohaze-editor" "${EDITOR:-vim}")"
    export TECHNO_HAZE_PROJECT_MIN_DEPTH="$(get_tmux_option "@technohaze-project-depth-min" "3")"
    export TECHNO_HAZE_PROJECT_MAX_DEPTH="$(get_tmux_option "@technohaze-project-depth-max" "3")"
    export TECHNO_HAZE_POPUP_WIDTH="$(get_tmux_option "@technohaze-popup-width" "70%")"
    export TECHNO_HAZE_POPUP_HEIGHT="$(get_tmux_option "@technohaze-popup-height" "60%")"

    # Logging options
    export TECHNO_HAZE_LOG_LEVEL="$(get_tmux_option "@technohaze-log-level" "warnings")"
    export TECHNO_HAZE_NOTIFICATION_TYPE="$(get_tmux_option "@technohaze-notification-type" "off")"
    export TECHNO_HAZE_NOTIFICATION_COMMAND="$(get_tmux_option "@technohaze-notification-command" "")"
    export TECHNO_HAZE_LOG_FILE="$(get_tmux_option "@technohaze-log-file" "$HOME/.cache/techno-haze-tmux/plugin.log")"

    # Status bar options
    export TECHNO_HAZE_ICON="$(get_tmux_option "@technohaze-icon" "💜")"
    export TECHNO_HAZE_ICON_ACTIVE="$(get_tmux_option "@technohaze-icon-active" "💗")"
    export TECHNO_HAZE_PLUGINS="$(get_tmux_option "@technohaze-plugins" "cpu ram")"
    export TECHNO_HAZE_WINDOW_COLOR="$(get_tmux_option "@technohaze-window-color" "#792EC0")"
    export TECHNO_HAZE_PLUGIN_COLOR="$(get_tmux_option "@technohaze-plugin-color" "#E06666")"

    # Expand tilde in log file path
    TECHNO_HAZE_LOG_FILE="${TECHNO_HAZE_LOG_FILE/#\~/$HOME}"
}

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
