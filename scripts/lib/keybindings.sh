#!/usr/bin/env bash

# --- Configuration Constants -------------------------------------------------
readonly WINDOW_SELECTION_START=0
readonly WINDOW_SELECTION_END=9
readonly WINDOW_ZERO_TARGET=10
readonly RESIZE_HORIZONTAL_LARGE=4
readonly RESIZE_VERTICAL_SMALL=2

# --- Key Bindings Setup ------------------------------------------------------

# Function: setup_keys
# Description: Sets up all tmux key bindings for navigation, panes, windows, and plugins
# Parameters: None
# Returns: 0 on success
# Side Effects: Binds 30+ key combinations, uses SCRIPT_DIR, TECHNO_HAZE_PROJECTS_DIR, TECHNO_HAZE_EDITOR env vars
setup_keys() {

    tmux bind r source-file ~/.config/tmux/tmux.conf

    # Tmux + Neovim navigation integration
    bind_vim 'M-h' 'send-keys M-h' 'select-pane -L'
    bind_vim 'M-j' 'send-keys M-j' 'select-pane -D'
    bind_vim 'M-k' 'send-keys M-k' 'select-pane -U'
    bind_vim 'M-l' 'send-keys M-l' 'select-pane -R'
    bind_vim 'M-H' 'send-keys M-H' "resize-pane -L $RESIZE_HORIZONTAL_LARGE"
    bind_vim 'M-J' 'send-keys M-J' "resize-pane -D $RESIZE_VERTICAL_SMALL"
    bind_vim 'M-K' 'send-keys M-K' "resize-pane -U $RESIZE_VERTICAL_SMALL"
    bind_vim 'M-L' 'send-keys M-L' "resize-pane -R $RESIZE_HORIZONTAL_LARGE"
    bind_vim 'M-C-h' 'send-keys M-C-h' 'run-shell "tmux select-pane -L \\; swap-pane -d -s #D"'
    bind_vim 'M-C-j' 'send-keys M-C-j' 'run-shell "tmux select-pane -D \\; swap-pane -d -s #D"'
    bind_vim 'M-C-k' 'send-keys M-C-k' 'run-shell "tmux select-pane -U \\; swap-pane -d -s #D"'
    bind_vim 'M-C-l' 'send-keys M-C-l' 'run-shell "tmux select-pane -R \\; swap-pane -d -s #D"'

    tmux bind -n 'M-C-s' command-prompt -p "Swap window:","With Window:" "swap-window -s '%1' -t '%2'"

    # Window selection
    for i in $(seq $WINDOW_SELECTION_START $WINDOW_SELECTION_END); do
        tmux bind-key -n "M-$i" select-window -t "$i"
        [[ "$i" == $WINDOW_SELECTION_START ]] && bind_key 'M-0' "select-window -t $WINDOW_ZERO_TARGET"
    done

    # Window and pane management
    tmux bind -n 'M-Tab' next-window
    tmux bind -n 'M-BTab' previous-window
    tmux bind -n 'M--' 'split-window -v -c "#{pane_current_path}"'
    tmux bind -n 'M-\' 'split-window -h -c "#{pane_current_path}"'
    tmux bind -n 'M-x' kill-pane
    tmux bind -n 'M-w' confirm-before -p "Kill window #W? (y/n)" kill-window
    tmux bind -n 'M-t' new-window
    tmux bind -n 'M-c' copy-mode
    tmux bind -n 'M-y' set-window-option synchronize-panes

    # Project launcher (with configurable dimensions)
    if [[ -x "$SCRIPT_DIR/projects.sh" ]]; then
        local popup_width="$(get_tmux_option "@technohaze-popup-width" "70%")"
        local popup_height="$(get_tmux_option "@technohaze-popup-height" "60%")"

        tmux bind -n M-p display-popup -E -w "$popup_width" -h "$popup_height" \
            -T "Project Launcher" "$SCRIPT_DIR/projects.sh" \
            "$TECHNO_HAZE_PROJECTS_DIR" "$TECHNO_HAZE_EDITOR" \
            || log_warn "Failed to bind project launcher"
    else
        log_warn "projects.sh not found or not executable"
    fi

    # Copy mode: ESC to cancel
    tmux bind -T copy-mode-vi Escape send-keys -X cancel

    # Zoom
    tmux unbind z
    tmux bind -n 'M-f' 'resize-pane -Z'
}
