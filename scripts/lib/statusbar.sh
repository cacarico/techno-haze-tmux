#!/usr/bin/env bash

# --- Configuration Constants -------------------------------------------------
readonly STATUS_LEFT_LENGTH=100
readonly STATUS_RIGHT_LENGTH=100

# --- Status Bar Configuration ------------------------------------------------

# Function: setup_statusbar
# Description: Configures tmux status bar appearance, colors, and plugin output
# Parameters: None
# Returns: 0 on success
# Side Effects: Sets status bar options, builds dynamic plugin script output
# Note: Assumes user options are already initialized via init_user_options()
setup_statusbar() {
    # Use exported configuration variables
    local icon_inactive="$TECHNO_HAZE_ICON"
    local icon_active="$TECHNO_HAZE_ICON_ACTIVE"
    local plugins="$TECHNO_HAZE_PLUGINS"
    local window_color="$TECHNO_HAZE_WINDOW_COLOR"
    local plugin_color="$TECHNO_HAZE_PLUGIN_COLOR"
    local border_color="$TECHNO_HAZE_BORDER_COLOR"

    if [[ -z "${SCRIPT_DIR:-}" ]]; then
        log_error "SCRIPT_DIR is not set; cannot configure status bar plugins"
        return 1
    fi

    # Status bar layout
    tmux set-option -g status-left-length $STATUS_LEFT_LENGTH
    tmux set-option -g status-right-length $STATUS_RIGHT_LENGTH
    tmux set-option -g status-right ''

    # Build plugin output script with validation
    local script=""
    for plugin in $plugins; do
        case "$plugin" in
            "cpu")
                if [[ -x "$SCRIPT_DIR/cpu.sh" ]]; then
                    script+="#($SCRIPT_DIR/cpu.sh) "
                else
                    log_warn "cpu.sh not found or not executable"
                fi
                ;;
            "ram")
                if [[ -x "$SCRIPT_DIR/ram.sh" ]]; then
                    script+="#($SCRIPT_DIR/ram.sh) "
                else
                    log_warn "ram.sh not found or not executable"
                fi
                ;;
            "kube")
                if [[ -x "$SCRIPT_DIR/kube.sh" ]]; then
                    script+="#($SCRIPT_DIR/kube.sh) "
                else
                    log_warn "kube.sh not found or not executable"
                fi
                ;;
            "gcp")
                if [[ -x "$SCRIPT_DIR/gcp.sh" ]]; then
                    script+="#($SCRIPT_DIR/gcp.sh) "
                else
                    log_warn "gcp.sh not found or not executable"
                fi
                ;;
            *)
                log_warn "Unknown plugin: $plugin"
                ;;
        esac
    done

    # Apply status bar styling
    tmux set-option -g status-left " #{?client_prefix,${icon_active},${icon_inactive}} "
    tmux set-option -g status-style "bg=default"
    tmux set-option -g status-right "$script"
    tmux set-option -g message-style "bg=default,fg=${border_color}"
    tmux set-option -g pane-border-style "bg=default fg=${border_color}"
    tmux set-option -g pane-active-border-style "bg=default fg=${border_color}"
    tmux set-window-option -g window-status-format "#I.#W"
    tmux set-window-option -g window-status-current-format "#[fg=${window_color}]#I.#W"
    log_info "Status bar configured with plugins: $plugins"

    # Rename window shortcut
    tmux bind -n M-r command-prompt -I "#W" "rename-window '%%'"
}
