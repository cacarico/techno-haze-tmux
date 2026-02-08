#!/usr/bin/env bash

# --- Utility Functions -------------------------------------------------------

# Function: get_tmux_option
# Description: Retrieves a tmux option value or returns default if not set
# Parameters:
#   $1 - option (string): Tmux option name (e.g., "@technohaze-projects-dir")
#   $2 - default_value (string): Value to return if option is not set
# Returns: Option value or default value via stdout
# Example: projects_dir=$(get_tmux_option "@technohaze-projects-dir" "$HOME/ghq")
get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local value

    if ! value="$(tmux show-option -gqv "$option" 2>/dev/null)"; then
        echo "$default_value"
        return 0
    fi

    [[ -z "$value" ]] && echo "$default_value" || echo "$value"
}

# Function: bind_key
# Description: Binds a key to a tmux command in root key table
# Parameters:
#   $1 - key (string): Key combination (e.g., "M-h", "C-a")
#   $2 - command (string): Tmux command to execute
# Returns: 0 on success, 1 on failure
# Example: bind_key "M-h" "select-pane -L"
bind_key() {
    local key="$1"
    local command="$2"

    if ! tmux bind-key -n "$key" "$command" 2>/dev/null; then
        echo "[TECHNO-HAZE WARN] Failed to bind key '$key'" >&2
        return 1
    fi
}

# Function: bind_vim
# Description: Creates vim-aware key binding that checks if vim is running
# Parameters:
#   $1 - key (string): Key combination to bind
#   $2 - cmd_vim (string): Command to send if vim is detected
#   $3 - cmd_tmux (string): Tmux command if vim is not detected
# Returns: 0 on success, 1 on failure
# Example: bind_vim 'M-h' 'send-keys M-h' 'select-pane -L'
bind_vim() {
    local key="$1"
    local cmd_vim="$2"
    local cmd_tmux="$3"

    local is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

    if ! tmux bind-key -n "$key" if-shell "$is_vim" "$cmd_vim" "$cmd_tmux" 2>/dev/null; then
        echo "[TECHNO-HAZE WARN] Failed to bind vim-aware key '$key'" >&2
        return 1
    fi
}
