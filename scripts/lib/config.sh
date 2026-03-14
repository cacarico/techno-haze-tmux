#!/usr/bin/env bash

# --- Tmux Configuration Constants --------------------------------------------
readonly DEFAULT_TERMINAL="screen-256color"
readonly HISTORY_LIMIT=5000
readonly BASE_INDEX=1
readonly DISPLAY_PANES_TIME=801
readonly DISPLAY_MESSAGE_TIME=1000
readonly STATUS_INTERVAL=10

# --- User Option Defaults ----------------------------------------------------

# Project launcher defaults
readonly DEFAULT_PROJECTS_DIR="$HOME/ghq"
readonly DEFAULT_EDITOR="${EDITOR:-vim}"
readonly DEFAULT_PROJECT_MIN_DEPTH="3"
readonly DEFAULT_PROJECT_MAX_DEPTH="3"
readonly DEFAULT_POPUP_WIDTH="70%"
readonly DEFAULT_POPUP_HEIGHT="60%"

# Logging defaults
readonly DEFAULT_LOG_LEVEL="warnings"
readonly DEFAULT_NOTIFICATION_TYPE="off"
readonly DEFAULT_NOTIFICATION_COMMAND=""
readonly DEFAULT_LOG_FILE="$HOME/.cache/techno-haze-tmux/plugin.log"

# Status bar defaults
readonly DEFAULT_ICON="💜"
readonly DEFAULT_ICON_ACTIVE="💗"
readonly DEFAULT_PLUGINS="cpu ram"

# Color palette
readonly COLOR_PURPLE="#792EC0"
readonly COLOR_RED="#E06666"
readonly COLOR_BLUE="#6BAFED"
readonly COLOR_PINK="#F48FB1"
readonly COLOR_LIGHT_PURPLE="#B39DDB"
readonly COLOR_ORANGE="#FFB86C"

# --- User Options Initialization ---------------------------------------------

# Function: init_user_options
# Description: Fetches all user-configurable tmux options and exports them as environment variables
# Parameters: None
# Returns: 0 on success
# Side Effects: Exports all TECHNO_HAZE_* environment variables
# Note: This is the single source of truth for all plugin configuration
init_user_options() {
    # Project launcher options
    export TECHNO_HAZE_PROJECTS_DIR="$(get_tmux_option "@technohaze-projects-dir" "$DEFAULT_PROJECTS_DIR")"
    export TECHNO_HAZE_EDITOR="$(get_tmux_option "@technohaze-editor" "$DEFAULT_EDITOR")"
    export TECHNO_HAZE_PROJECT_MIN_DEPTH="$(get_tmux_option "@technohaze-project-depth-min" "$DEFAULT_PROJECT_MIN_DEPTH")"
    export TECHNO_HAZE_PROJECT_MAX_DEPTH="$(get_tmux_option "@technohaze-project-depth-max" "$DEFAULT_PROJECT_MAX_DEPTH")"
    export TECHNO_HAZE_POPUP_WIDTH="$(get_tmux_option "@technohaze-popup-width" "$DEFAULT_POPUP_WIDTH")"
    export TECHNO_HAZE_POPUP_HEIGHT="$(get_tmux_option "@technohaze-popup-height" "$DEFAULT_POPUP_HEIGHT")"

    # Logging options
    export TECHNO_HAZE_LOG_LEVEL="$(get_tmux_option "@technohaze-log-level" "$DEFAULT_LOG_LEVEL")"
    export TECHNO_HAZE_NOTIFICATION_TYPE="$(get_tmux_option "@technohaze-notification-type" "$DEFAULT_NOTIFICATION_TYPE")"
    export TECHNO_HAZE_NOTIFICATION_COMMAND="$(get_tmux_option "@technohaze-notification-command" "$DEFAULT_NOTIFICATION_COMMAND")"
    export TECHNO_HAZE_LOG_FILE="$(get_tmux_option "@technohaze-log-file" "$DEFAULT_LOG_FILE")"

    # Status bar options
    export TECHNO_HAZE_ICON="$(get_tmux_option "@technohaze-icon" "$DEFAULT_ICON")"
    export TECHNO_HAZE_ICON_ACTIVE="$(get_tmux_option "@technohaze-icon-active" "$DEFAULT_ICON_ACTIVE")"
    export TECHNO_HAZE_PLUGINS="$(get_tmux_option "@technohaze-plugins" "$DEFAULT_PLUGINS")"
    export TECHNO_HAZE_WINDOW_COLOR="$(get_tmux_option "@technohaze-window-color" "$COLOR_PURPLE")"
    export TECHNO_HAZE_PLUGIN_COLOR="$(get_tmux_option "@technohaze-plugin-color" "$COLOR_RED")"
    export TECHNO_HAZE_BORDER_COLOR="$(get_tmux_option "@technohaze-border-color" "$COLOR_PURPLE")"

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
