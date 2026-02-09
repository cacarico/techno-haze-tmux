#!/usr/bin/env bash

# --- Configuration Constants -------------------------------------------------
readonly COLOR_GRAY='#7A7276DB'
readonly COLOR_PINK='#D100AEDB'
readonly COLOR_PURPLE='#792EC0'
readonly COLOR_RED='#E06666'
readonly DEFAULT_ICON_INACTIVE="💜"
readonly DEFAULT_ICON_ACTIVE="💗"
readonly DEFAULT_PLUGINS="cpu ram"
readonly STATUS_LEFT_LENGTH=100
readonly STATUS_RIGHT_LENGTH=100

# --- Status Bar Configuration ------------------------------------------------

# Function: setup_statusbar
# Description: Configures tmux status bar appearance, colors, and plugin output
# Parameters: None
# Returns: 0 on success
# Side Effects: Sets status bar options, builds dynamic plugin script output
setup_statusbar() {
    # Icons
    local icon_inactive="$(get_tmux_option "@technohaze-icon" "$DEFAULT_ICON_INACTIVE")"
    local icon_active="$(get_tmux_option "@technohaze-icon-active" "$DEFAULT_ICON_ACTIVE")"
    local plugins="$(get_tmux_option "@technohaze-plugins" "$DEFAULT_PLUGINS")"

    # Color palette (with configurable overrides)
    local window_color="$(get_tmux_option "@technohaze-window-color" "$COLOR_PURPLE")"
    local plugin_color="$(get_tmux_option "@technohaze-plugin-color" "$COLOR_RED")"

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
            *)
                log_warn "Unknown plugin: $plugin"
                ;;
        esac
    done

    # Apply status bar styling
    tmux set-option -g status-left " #{?client_prefix,${icon_active},${icon_inactive}} "
    tmux set-option -g status-style "bg=default"
    tmux set-option -g status-right "#[fg=${plugin_color}]$script"
    tmux set-option -g message-style "bg=default,fg=${COLOR_PURPLE}"
    tmux set-option -g pane-border-style "bg=default fg=${COLOR_PURPLE}"
    tmux set-option -g pane-active-border-style "bg=default fg=${COLOR_PURPLE}"
    tmux set-window-option -g window-status-format "#I.#W"
    tmux set-window-option -g window-status-current-format "#[fg=${window_color}]#I.#W"

    # Rename window shortcut
    tmux bind -n M-r command-prompt -I "#W" "rename-window '%%'"
}
