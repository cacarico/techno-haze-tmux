#!/usr/bin/env bash

set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LC_ALL=en_US.UTF-8

# --- Utility Functions -------------------------------------------------------

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local value
    value="$(tmux show-option -gqv "$option")"
    [[ -z "$value" ]] && echo "$default_value" || echo "$value"
}

bind_key() {
    local key="$1"
    local command="$2"
    tmux bind-key -n "$key" "$command"
}

bind_vim() {
    local key="$1"
    local cmd_vim="$2"
    local cmd_tmux="$3"

    local is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

    tmux bind-key -n "$key" if-shell "$is_vim" "$cmd_vim" "$cmd_tmux"
}

# --- Key Bindings Setup ------------------------------------------------------

setup_keys() {

    tmux bind r source-file ~/.config/tmux/tmux.conf

    # Tmux + Neovim navigation integration
    bind_vim 'M-h' 'send-keys M-h' 'select-pane -L'
    bind_vim 'M-j' 'send-keys M-j' 'select-pane -D'
    bind_vim 'M-k' 'send-keys M-k' 'select-pane -U'
    bind_vim 'M-l' 'send-keys M-l' 'select-pane -R'
    bind_vim 'M-H' 'send-keys M-H' 'resize-pane -L 4'
    bind_vim 'M-J' 'send-keys M-J' 'resize-pane -D 2'
    bind_vim 'M-K' 'send-keys M-K' 'resize-pane -U 2'
    bind_vim 'M-L' 'send-keys M-L' 'resize-pane -R 4'
    bind_vim 'M-C-h' 'send-keys M-C-h' 'run-shell "tmux select-pane -L \\; swap-pane -d -s #D"'
    bind_vim 'M-C-j' 'send-keys M-C-j' 'run-shell "tmux select-pane -D \\; swap-pane -d -s #D"'
    bind_vim 'M-C-k' 'send-keys M-C-k' 'run-shell "tmux select-pane -U \\; swap-pane -d -s #D"'
    bind_vim 'M-C-l' 'send-keys M-C-l' 'run-shell "tmux select-pane -R \\; swap-pane -d -s #D"'

    tmux bind -n 'M-C-s' command-prompt -p "Swap window:","With Window:" "swap-window -s '%1' -t '%2'"

    # Window selection
    for i in $(seq 0 9); do
        tmux bind-key -n "M-$i" select-window -t "$i"
        [[ "$i" == 0 ]] && bind_key 'M-0' 'select-window -t 10'
    done

    # Window and pane management
    tmux bind -n 'M-Tab' next-window
    tmux bind -n 'M-BTab' previous-window
    tmux bind -n 'M--' 'split-window -v'
    tmux bind -n 'M-\' 'split-window -h'
    tmux bind -n 'M-x' kill-pane
    tmux bind -n 'M-w' kill-window
    tmux bind -n 'M-t' new-window
    tmux bind -n 'M-c' copy-mode
    tmux bind -n 'M-y' set-window-option synchronize-panes

    # Project
    tmux bind -n M-p display-popup -E -w 90% -h 60% -T "Project Launcher" "$CURRENT_DIR/projects.sh" "$projects_dir" "$editor"

    # Copy mode: ESC to cancel
    tmux bind -T copy-mode-vi Escape send-keys -X cancel

    # Zoom
    tmux unbind z
    tmux bind -n 'M-f' 'resize-pane -Z'
}

# --- Tmux Options ------------------------------------------------------------

setup_config() {
    tmux set-option -g prefix M-a
    tmux bind-key M-a send-prefix

    tmux set -g mouse on
    tmux set -g default-terminal "screen-256color"
    tmux set -g history-limit 5000
    tmux set-window-option -g mode-keys vi

    tmux set -g base-index 1
    tmux set -g renumber-windows on
    tmux set -g display-panes-time 801
    tmux set -g display-time 1000
    tmux set -g status-interval 10
    tmux setw -g automatic-rename off

    # Image preview fix (e.g. yazi)
    tmux set -g allow-passthrough on
    tmux set -ga update-environment TERM
    tmux set -ga update-environment TERM_PROGRAM
}

# --- Main --------------------------------------------------------------------

main() {
    # Icons
    local purple_heart="💜"
    local pink_heart="💗"
    local icon_inactive="$(get_tmux_option "@technohaze-icon" "$purple_heart")"
    local icon_active="$(get_tmux_option "@technohaze-icon-active" "$pink_heart")"
    local plugins="$(get_tmux_option "@technohaze-plugins" "cpu ram")"
    local projects_dir="$(get_tmux_option "@technohaze-projects-dir" "$HOME/ghq")"

    editor="$(get_tmux_option "@technohaze-editor" "$EDITOR")"
    # Color palette
    local gray='#7A7276DB'
    local pink='#D100AEDB'
    local purple='#792EC0'
    local red='#E06666'

    local window_color="$purple"
    local plugin_color="$red"

    setup_config
    setup_keys


    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100
    tmux set-option -g status-right ''

    # Plugin output script
    local script=""
    for plugin in $plugins; do
        case "$plugin" in
            "cpu") script+="#($CURRENT_DIR/cpu.sh) " ;;
            "ram") script+="#($CURRENT_DIR/ram.sh) " ;;
            *)     script="NOT FOUND" ;;
        esac
    done

    # Status bar configuration
    tmux set-option -g status-left " #{?client_prefix,${icon_active},${icon_inactive}} "
    tmux set-option -g status-style "bg=default"
    tmux set-option -g status-right "#[fg=${purple}]$script"
    tmux set-option -g message-style "bg=default,fg=${purple}"
    tmux set-option -g pane-border-style "bg=default fg=${purple}"
    tmux set-option -g pane-active-border-style "bg=default fg=${purple}"
    tmux set-window-option -g window-status-format "#I.#W"
    tmux set-window-option -g window-status-current-format "#[fg=${window_color}]#I.#W"

    # Rename window shortcut
    tmux bind -n M-r command-prompt -I "#W" "rename-window '%%'"
}

main
